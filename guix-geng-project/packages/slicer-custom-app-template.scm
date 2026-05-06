;;
;; slicer-custom-app-template.scm
;;
;; Inherits from systole's slicer-5.8 (all 76+ patches, Python enabled) and
;; appends the cmake flags needed to build SlicerCustomAppTemplate in place of
;; the default SlicerApp.  Binary-name-specific phases (patch-runpath,
;; install-slicer-symlink) are replaced to reference SlicerCustomAppTemplate-real.
;;

(define-module (guix-geng-project packages slicer-custom-app-template)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system cmake)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix search-paths)
  #:use-module (guix utils)
  #:use-module (gnu packages image-processing)  ; for dcmtk
  #:use-module (gnu packages web)               ; for rapidjson
  #:use-module (srfi srfi-1)                    ; for fold
  #:use-module (systole packages)        ; sets up %patch-path for slicer-5.8's patches
  #:use-module (systole packages slicer))

;; SlicerCustomAppTemplate git checkout — provides Applications/, Modules/, etc.
(define template-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/DavinhDang/SlicerCustomAppTemplate")
          (commit "01777b409a9d7ef0f19d12604024de286b10697b")))
    (file-name "SlicerCustomAppTemplate-checkout")
    (sha256
     (base32 "0hx0cn67ksy1825jag2wixbnfm9z752ngs39ahwpcrc1cv94bm0j"))
    (patches
     (list (local-file "patches/slicer-custom-app-template-fix-main-window.patch")
           (local-file "patches/slicer-custom-app-template-fix-main-cxx.patch")))))

(define-public slicer-custom-app-template
  (package
    (inherit slicer-5.8)
    (name "slicer-custom-app-template")
    (version "2025.02.12")
    (arguments
     (substitute-keyword-arguments (package-arguments slicer-5.8)
       ;; Append custom-app cmake flags on top of all slicer-5.8 flags.
       ((#:configure-flags flags)
        #~(append #$flags
                  (list
                   ;; Disable application-update support (requires qRestAPI
                   ;; USE_FILE which is unavailable when EXTENSIONMANAGER is OFF).
                   "-DSlicer_BUILD_APPLICATIONUPDATE_SUPPORT:BOOL=OFF"

                   ;; -------------------------------------------------------
                   ;; Custom application (SlicerCustomAppTemplate)
                   ;; -------------------------------------------------------
                   "-DSlicer_MAIN_PROJECT=SlicerCustomAppTemplateApp"
                   (string-append "-DSlicer_APPLICATIONS_DIR="
                                  #$template-source "/Applications")
                   ;; Referenced in slicer-application-properties.cmake for the
                   ;; LICENSE path.
                   (string-append "-DSlicerCustomAppTemplate_SOURCE_DIR="
                                  #$template-source)

                   ;; Extension source dirs: Python scripted modules only.
                   ;; LoadableMVoxMeshGen is a C++ loadable module — it must be
                   ;; built after install via find_package(Slicer) (like myext).
                   ;; slicerMacroBuildLoadableModule is only in UseSlicer.cmake
                   ;; (post-install path), never in the main build cmake context.
                   (string-append "-DSlicer_EXTENSION_SOURCE_DIRS="
                                  #$template-source "/Modules/Scripted/Home;"
                                  (getcwd) "/SlicerCustomAppUtilities/Modules/Scripted/SlicerCustomAppUtilities")

                   ;; App metadata
                   "-DSlicer_ORGANIZATION_DOMAIN=kitware.com"
                   "-DSlicer_ORGANIZATION_NAME=Kitware, Inc."
                   "-DSlicer_DEFAULT_HOME_MODULE=Home"
                   "-DSlicer_DEFAULT_FAVORITE_MODULES=Data, Volumes, Models, Transforms, Markups, SegmentEditor"

                   ;; Module enable/disable lists (from template CMakeLists.txt)
                   "-DSlicer_CLIMODULES_ENABLED=ResampleDTIVolume;ResampleScalarVectorDWIVolume"
                   "-DSlicer_QTLOADABLEMODULES_DISABLED=SceneViews;SlicerWelcome;ViewControllers"
                   "-DSlicer_BUILD_DIFFUSION_SUPPORT:BOOL=ON"
                   "-DSlicer_QTSCRIPTEDMODULES_DISABLED=DataProbe;Endoscopy;LabelStatistics;PerformanceTests;SampleData;VectorToScalarVolume")))

       ((#:phases phases)
        #~(modify-phases #$phases
            ;; Extract SlicerCustomAppUtilities before configure so that
            ;; (getcwd)/SlicerCustomAppUtilities resolves correctly in the
            ;; configure-flags above.
            (add-before 'configure 'extract-slicercustomapputilities
              (lambda _
                (mkdir-p "../SlicerCustomAppUtilities")
                (invoke "tar" "--strip-components=1" "-xf"
                        #$(origin
                            (method url-fetch)
                            (uri "https://github.com/KitwareMedical/SlicerCustomAppUtilities/archive/1d984a2c9143e2617ff1ffa9d86c51e07dc6321e.tar.gz")
                            (sha256
                             (base32 "1qyzfsdz64pkd87iixjkiqasxxqsdiwpxpca7nsnszs6yr3aswkb")))
                        "-C" "../SlicerCustomAppUtilities")
                #t))

            ;; The custom app installs libs to lib/SlicerCustomAppTemplate-5.8/,
            ;; not lib/Slicer-5.8/, so every inherited phase that hardcodes the
            ;; Slicer-5.8 path must be replaced.

            ;; Our binary is SlicerCustomAppTemplate-real, not SlicerApp-real.
            (replace 'patch-runpath
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (bin (string-append out "/bin/SlicerCustomAppTemplateApp-real")))
                  (when (file-exists? bin)
                    (invoke "patchelf" "--add-rpath"
                            (string-append "$ORIGIN/../lib/SlicerCustomAppTemplate-5.8"
                                           ":"
                                           "$ORIGIN/../lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules")
                            bin)))
                #t))

            ;; Install a bin/SlicerCustomAppTemplate wrapper instead of bin/Slicer.
            ;; Pre-populate LD_LIBRARY_PATH from SLICER_ADDITIONAL_MODULE_PATHS so
            ;; that module .so files are found before Slicer's dlopen calls (glibc
            ;; caches LD_LIBRARY_PATH at process start; setting it after exec is too
            ;; late).  Also include $GUIX_ENVIRONMENT's qt-loadable-modules when set.
            (replace 'install-slicer-symlink
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (wrapper (string-append out "/bin/SlicerCustomAppTemplate")))
                  (when (file-exists? wrapper)
                    (delete-file wrapper))
                  (call-with-output-file wrapper
                    (lambda (port)
                      (display "#!/bin/sh\n" port)
                      (display "IFS=:\n" port)
                      (display "for _d in $SLICER_ADDITIONAL_MODULE_PATHS; do\n" port)
                      (display "  LD_LIBRARY_PATH=\"$_d${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"\n" port)
                      (display "done\n" port)
                      (display "unset IFS\n" port)
                      (display "if [ -n \"$GUIX_ENVIRONMENT\" ]; then\n" port)
                      (display "  _guix_mods=\"$GUIX_ENVIRONMENT/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules\"\n" port)
                      (display "  if [ -d \"$_guix_mods\" ]; then\n" port)
                      (display "    LD_LIBRARY_PATH=\"$_guix_mods${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"\n" port)
                      (display "  fi\n" port)
                      (display "fi\n" port)
                      (display "export LD_LIBRARY_PATH\n" port)
                      (display "export PIP_USER=1\n" port)
                      (display "_dir=\"$(dirname \"$(readlink -f \"$0\")\")\"\n" port)
                      (display "exec \"$_dir/SlicerCustomAppTemplateApp-real\" \"$@\"\n" port)))
                  (chmod wrapper #o755))
                #t))

            ;; Patch .so rpath for Python extensions in lib/SlicerCustomAppTemplate-5.8/.
            (replace 'patch-python-extension-runpath
              (lambda* (#:key outputs #:allow-other-keys)
                (let ((dir (string-append (assoc-ref outputs "out")
                                          "/lib/SlicerCustomAppTemplate-5.8")))
                  (for-each
                   (lambda (lib) (invoke "patchelf" "--add-rpath" "$ORIGIN" lib))
                   (find-files dir
                     (lambda (f stat)
                       (let ((rel (string-drop f (1+ (string-length dir)))))
                         (and (string-suffix? ".so" rel)
                              (not (string-contains rel "/"))))))))))

            ;; Symlink vtkAddonPython.so into lib/SlicerCustomAppTemplate-5.8/.
            (replace 'link-vtkaddon-python
              (lambda* (#:key inputs outputs #:allow-other-keys)
                (symlink
                 (string-append (assoc-ref inputs "vtkaddon")
                                "/lib/vtkAddonPython.so")
                 (string-append (assoc-ref outputs "out")
                                "/lib/SlicerCustomAppTemplate-5.8/vtkAddonPython.so"))))))))

    ;; The inherited native-search-paths from slicer-5.8 hardcode lib/Slicer-5.8/.
    ;; Override them to point at lib/SlicerCustomAppTemplate-5.8/ instead so that
    ;; PYTHONPATH and SLICER_ADDITIONAL_MODULE_PATHS are set correctly in any
    ;; profile that includes this package.
    (native-search-paths
     (list
      (search-path-specification
       (variable "CMAKE_PREFIX_PATH")
       (files '("")))
      (search-path-specification
       (variable "SLICER_ADDITIONAL_MODULE_PATHS")
       (files '("lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"
                "lib/SlicerCustomAppTemplate-5.8/qt-scripted-modules"
                "lib/SlicerCustomAppTemplate-5.8/cli-modules")))
      (search-path-specification
       (variable "SLICER_PYTHONPATH")
       (files '("bin/Python"
                "lib/SlicerCustomAppTemplate-5.8"
                "lib/python3.11/site-packages")))
      (search-path-specification
       (variable "PYTHONPATH")
       (files '("bin/Python"
                "lib/SlicerCustomAppTemplate-5.8"
                "lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"
                "lib/SlicerCustomAppTemplate-5.8/qt-scripted-modules"
                "lib/python3.11/site-packages")))))

    (home-page "https://github.com/DavinhDang/SlicerCustomAppTemplate")
    (license license:bsd-3)))

;;;
;;; Standalone loadable-module factory for SlicerCustomAppTemplate
;;;
;;; Mirrors systole's make-slicer-loadable-module but points Slicer_DIR at
;;; slicer-custom-app-template/lib/SlicerCustomAppTemplate-5.8 so the modules
;;; link against the custom app's libraries (avoiding ABI mismatch with
;;; slicer-5.8's store paths).  Install paths use SlicerCustomAppTemplate-5.8
;;; instead of Slicer-5.8 throughout.
;;;

(define* (make-slicer-loadable-module-custom-app
          #:key
          name           ; package name string
          module-subdir  ; Modules/Loadable/<subdir>
          source         ; origin — use (package-source slicer-xxx-5.8)
          synopsis
          description
          (extra-inputs '())
          (extra-configure-flags #~'())
          (propagated-inputs '()))
  (package
   (name name)
   (version (package-version slicer-custom-app-template))
   (source source)
   (build-system cmake-build-system)
   (arguments
    (list #:tests? #f
          #:validate-runpath? #f
          #:out-of-source? #t
          #:configure-flags
          #~(append
             (list "-DCMAKE_BUILD_TYPE:STRING=Release"
                   "-DBUILD_TESTING:BOOL=OFF"
                   "-DSlicer_INSTALL_DEVELOPMENT:BOOL=ON"
                   (string-append "-DSlicer_DIR="
                                  #$slicer-custom-app-template
                                  "/lib/SlicerCustomAppTemplate-5.8"))
             #$extra-configure-flags)
          #:phases
          #~(modify-phases %standard-phases
              (replace 'configure
                (lambda* (#:key inputs outputs configure-flags #:allow-other-keys)
                  (let* ((source (getcwd))
                         (out (assoc-ref outputs "out")))
                    (apply invoke "cmake"
                           "-S" (string-append source "/Modules/Loadable/"
                                               #$module-subdir)
                           "-B" "build"
                           (string-append "-DCMAKE_INSTALL_PREFIX=" out)
                           configure-flags)
                    (chdir "build")
                    #t))))))
   (inputs (fold (lambda (pkg acc)
                   (modify-inputs acc (prepend pkg)))
                 (modify-inputs (package-inputs slicer-custom-app-template)
                   (prepend slicer-custom-app-template))
                 extra-inputs))
   (propagated-inputs (cons slicer-custom-app-template propagated-inputs))
   (home-page (package-home-page slicer-custom-app-template))
   (synopsis synopsis)
   (description description)
   (license (package-license slicer-custom-app-template))))

;;;
;;; Module packages — dependency order
;;;

(define-public slicer-terminologies-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-terminologies-custom-app"
   #:module-subdir "Terminologies"
   #:source (package-source slicer-terminologies-5.8)
   #:synopsis "3D Slicer Terminologies module (SlicerCustomAppTemplate)"
   #:description
   "The Terminologies loadable module built against SlicerCustomAppTemplate."
   #:extra-configure-flags
   #~(list (string-append "-DRapidJSON_DIR="
                          #$rapidjson
                          "/lib/cmake/RapidJSON"))))

(define-public slicer-subjecthierarchy-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-subjecthierarchy-custom-app"
   #:module-subdir "SubjectHierarchy"
   #:source (package-source slicer-subjecthierarchy-5.8)
   #:synopsis "3D Slicer SubjectHierarchy module (SlicerCustomAppTemplate)"
   #:description
   "The SubjectHierarchy loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-terminologies-custom-app)
   #:propagated-inputs (list slicer-terminologies-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerTerminologiesModuleWidgets_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerTerminologiesModuleWidgets")
      (string-append
       "-DvtkSlicerTerminologiesModuleLogic_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerTerminologiesModuleLogic")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-terminologies-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-colors-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-colors-custom-app"
   #:module-subdir "Colors"
   #:source (package-source slicer-colors-5.8)
   #:synopsis "3D Slicer Colors module (SlicerCustomAppTemplate)"
   #:description
   "The Colors loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app)
   #:propagated-inputs (list slicer-subjecthierarchy-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-annotations-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-annotations-custom-app"
   #:module-subdir "Annotations"
   #:source (package-source slicer-annotations-5.8)
   #:synopsis "3D Slicer Annotations module (SlicerCustomAppTemplate)"
   #:description
   "The Annotations loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app)
   #:propagated-inputs (list slicer-subjecthierarchy-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-units-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-units-custom-app"
   #:module-subdir "Units"
   #:source (package-source slicer-units-5.8)
   #:synopsis "3D Slicer Units module (SlicerCustomAppTemplate)"
   #:description
   "The Units loadable module built against SlicerCustomAppTemplate."))

(define-public slicer-cameras-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-cameras-custom-app"
   #:module-subdir "Cameras"
   #:source (package-source slicer-cameras-5.8)
   #:synopsis "3D Slicer Cameras module (SlicerCustomAppTemplate)"
   #:description
   "The Cameras loadable module built against SlicerCustomAppTemplate."))

(define-public slicer-data-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-data-custom-app"
   #:module-subdir "Data"
   #:source (package-source slicer-data-5.8)
   #:synopsis "3D Slicer Data module (SlicerCustomAppTemplate)"
   #:description
   "The Data loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-cameras-custom-app slicer-subjecthierarchy-custom-app)
   #:propagated-inputs (list slicer-cameras-custom-app slicer-subjecthierarchy-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DvtkSlicerCamerasModuleLogic_INCLUDE_DIRS="
       #$slicer-cameras-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerCamerasModuleLogic")
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-cameras-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-volumes-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-volumes-custom-app"
   #:module-subdir "Volumes"
   #:source (package-source slicer-volumes-5.8)
   #:synopsis "3D Slicer Volumes module (SlicerCustomAppTemplate)"
   #:description
   "The Volumes loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app slicer-colors-custom-app dcmtk)
   #:propagated-inputs (list slicer-colors-custom-app slicer-units-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DvtkSlicerColorsModuleLogic_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleLogic")
      (string-append
       "-DvtkSlicerColorsModuleMRML_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleMRML")
      (string-append
       "-DqSlicerColorsModuleWidgets_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerColorsModuleWidgets")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-colors-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-models-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-models-custom-app"
   #:module-subdir "Models"
   #:source (package-source slicer-models-5.8)
   #:synopsis "3D Slicer Models module (SlicerCustomAppTemplate)"
   #:description
   "The Models loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app
                        slicer-terminologies-custom-app
                        slicer-colors-custom-app)
   #:propagated-inputs (list slicer-colors-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DqSlicerTerminologiesModuleWidgets_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerTerminologiesModuleWidgets")
      (string-append
       "-DvtkSlicerTerminologiesModuleLogic_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerTerminologiesModuleLogic")
      (string-append
       "-DqSlicerColorsModuleWidgets_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerColorsModuleWidgets")
      (string-append
       "-DvtkSlicerColorsModuleLogic_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleLogic")
      (string-append
       "-DvtkSlicerColorsModuleMRML_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleMRML")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-terminologies-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-colors-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-markups-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-markups-custom-app"
   #:module-subdir "Markups"
   #:source (package-source slicer-markups-5.8)
   #:synopsis "3D Slicer Markups module (SlicerCustomAppTemplate)"
   #:description
   "The Markups loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app
                        slicer-annotations-custom-app
                        slicer-terminologies-custom-app
                        slicer-colors-custom-app)
   #:propagated-inputs (list slicer-colors-custom-app slicer-annotations-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append "-DRapidJSON_DIR=" #$rapidjson "/lib/cmake/RapidJSON")
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DqSlicerTerminologiesModuleWidgets_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerTerminologiesModuleWidgets")
      (string-append
       "-DvtkSlicerTerminologiesModuleLogic_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerTerminologiesModuleLogic")
      (string-append
       "-DvtkSlicerColorsModuleLogic_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleLogic")
      (string-append
       "-DvtkSlicerColorsModuleMRML_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerColorsModuleMRML")
      (string-append
       "-DqSlicerColorsModuleWidgets_INCLUDE_DIRS="
       #$slicer-colors-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerColorsModuleWidgets")
      (string-append
       "-DvtkSlicerAnnotationsModuleMRML_INCLUDE_DIRS="
       #$slicer-annotations-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerAnnotationsModuleMRML")
      (string-append
       "-DvtkSlicerAnnotationsModuleLogic_INCLUDE_DIRS="
       #$slicer-annotations-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerAnnotationsModuleLogic")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-terminologies-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-colors-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-annotations-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-transforms-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-transforms-custom-app"
   #:module-subdir "Transforms"
   #:source (package-source slicer-transforms-5.8)
   #:synopsis "3D Slicer Transforms module (SlicerCustomAppTemplate)"
   #:description
   "The Transforms loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app
                        slicer-markups-custom-app)
   #:propagated-inputs (list slicer-markups-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DvtkSlicerMarkupsModuleMRML_INCLUDE_DIRS="
       #$slicer-markups-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerMarkupsModuleMRML")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-markups-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))

(define-public slicer-segmentations-custom-app
  (make-slicer-loadable-module-custom-app
   #:name "slicer-segmentations-custom-app"
   #:module-subdir "Segmentations"
   #:source (package-source slicer-segmentations-5.8)
   #:synopsis "3D Slicer Segmentations module (SlicerCustomAppTemplate)"
   #:description
   "The Segmentations loadable module built against SlicerCustomAppTemplate."
   #:extra-inputs (list slicer-subjecthierarchy-custom-app
                        slicer-terminologies-custom-app
                        slicer-markups-custom-app)
   #:propagated-inputs (list slicer-markups-custom-app)
   #:extra-configure-flags
   #~(list
      (string-append
       "-DqSlicerSubjectHierarchyModuleWidgets_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerSubjectHierarchyModuleWidgets")
      (string-append
       "-DvtkSlicerSubjectHierarchyModuleLogic_INCLUDE_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerSubjectHierarchyModuleLogic")
      (string-append
       "-DqSlicerTerminologiesModuleWidgets_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/qSlicerTerminologiesModuleWidgets")
      (string-append
       "-DvtkSlicerTerminologiesModuleLogic_INCLUDE_DIRS="
       #$slicer-terminologies-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerTerminologiesModuleLogic")
      (string-append
       "-DvtkSlicerMarkupsModuleMRML_INCLUDE_DIRS="
       #$slicer-markups-custom-app
       "/include/SlicerCustomAppTemplate-5.8/qt-loadable-modules/vtkSlicerMarkupsModuleMRML")
      (string-append
       "-DEXTRA_MODULE_LIB_DIRS="
       #$slicer-subjecthierarchy-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-terminologies-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules;"
       #$slicer-markups-custom-app
       "/lib/SlicerCustomAppTemplate-5.8/qt-loadable-modules"))))
