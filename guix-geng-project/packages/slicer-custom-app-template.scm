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
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix search-paths)
  #:use-module (guix utils)
  #:use-module (systole packages)        ; sets up %patch-path for slicer-5.8's patches
  #:use-module (systole packages slicer))

;; SlicerCustomAppTemplate git checkout — provides Applications/, Modules/, etc.
(define template-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/DavinhDang/SlicerCustomAppTemplate")
          (commit "100ca6e652974688d3a243b6101a91a3ca257364")))
    (file-name "SlicerCustomAppTemplate-checkout")
    (sha256
     (base32 "0wizz72x1jlg5dri1ih310q1sgf1n08fx4gx4y5ns6wyh2mry8j5"))
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
                   "-DSlicer_QTSCRIPTEDMODULES_DISABLED=DataProbe;DMRIInstall;Endoscopy;LabelStatistics;PerformanceTests;SampleData;VectorToScalarVolume")))

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
            (replace 'install-slicer-symlink
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (wrapper (string-append out "/bin/SlicerCustomAppTemplate")))
                  (when (file-exists? wrapper)
                    (delete-file wrapper))
                  (call-with-output-file wrapper
                    (lambda (port)
                      (display "#!/bin/sh\n" port)
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
