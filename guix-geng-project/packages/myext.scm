(define-module (guix-geng-project packages myext)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages image)
  #:use-module (gnu packages python)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xml)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix gexp)
  #:use-module (systole packages slicer))

(define-public myext
  (package
    (name "myext")
    (version "0.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/DavinhDang/guix-geng-project")
              (commit "3cd45e98365d5a754886304d937a0818add3eea7")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "04l9d4mky261ixd106v749p25140a0wclrp6xj9xaa7zvnvr96ip"))))
    (build-system cmake-build-system)
    (arguments
      (list
        #:tests? #f
        #:configure-flags
        #~(list
            (string-append "-DSlicer_DIR:PATH="
                           #$(this-package-input "slicer-5.8")
                           "/lib/cmake/Slicer-5.8")
            "-DSlicer_SUPERBUILD:BOOL=OFF"
            "-DBUILD_TESTING:BOOL=OFF"
            "-DSlicer_BUILD_CLI_SUPPORT:BOOL=OFF"
            "-DSlicer_BUILD_CLI:BOOL=OFF"
            (string-append "-DPython3_ROOT_DIR="
                           #$(this-package-input "python")))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'enter-extension-dir
              (lambda _
                (chdir "myext")))
            (add-after 'enter-extension-dir 'patch-cpack
              (lambda _
                (substitute* "CMakeLists.txt"
                  (("include\\(\\$\\{Slicer_EXTENSION_CPACK\\}\\)")
                   "# CPack skipped for Guix packaging"))
                #t))
            (add-after 'patch-cpack 'add-slicer-base-logic
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((port (open-file "LoadableMVoxMeshGen/Logic/CMakeLists.txt" "a")))
                  (display
                   (string-append
                    "\ntarget_link_libraries(vtkSlicer${MODULE_NAME}ModuleLogic "
                    (assoc-ref inputs "slicer-5.8")
                    "/lib/Slicer-5.8/libSlicerBaseLogic.so)\n")
                   port)
                  (close-port port))
                #t))
            (add-before 'build 'set-library-path
              (lambda* (#:key inputs #:allow-other-keys)
                (setenv "LD_LIBRARY_PATH"
                        (string-append
                         (assoc-ref inputs "slicer-5.8") "/lib/Slicer-5.8:"
                         (assoc-ref inputs "slicer-5.8") "/lib:"
                         (or (getenv "LD_LIBRARY_PATH") "")))
                (setenv "LIBRARY_PATH"
                        (string-append
                         (assoc-ref inputs "slicer-5.8") "/lib/Slicer-5.8:"
                         (assoc-ref inputs "slicer-5.8") "/lib:"
                         (or (getenv "LIBRARY_PATH") "")))
                #t)))))
    (inputs
      (list slicer-5.8
            python
            libpng
            expat
            libjpeg-turbo
            freetype
            git))
    (synopsis "MVox mesh generation Slicer extension")
    (description
     "A 3D Slicer loadable module extension providing MVox mesh generation.")
    (home-page "https://github.com/DavinhDang/guix-geng-project")
    (license license:asl2.0)))
