(define-module (guix-geng-project packages myext)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages image)
  #:use-module (gnu packages python)
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
              (commit "e2a791797ea68ea3386f17223adeb7f1e8576481")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "04wdc98mz90r5xyxi229lf9blbkkimhhmm2s5zwb30mmxyf8zvzf"))))
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
            (string-append "-DPython3_ROOT_DIR="
                           #$(this-package-input "python")))
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'enter-extension-dir
              (lambda _
                (chdir "myext"))))))
    (inputs
      (list slicer-5.8
            python
            libpng
            expat
            libjpeg-turbo
            freetype))
    (synopsis "MVox mesh generation Slicer extension")
    (description
     "A 3D Slicer loadable module extension providing MVox mesh generation.")
    (home-page "https://github.com/DavinhDang/guix-geng-project")
    (license license:asl2.0)))
