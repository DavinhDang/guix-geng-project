(define-module (guix-geng-project packages myext)
  #:use-module ((guix licenses) #:prefix license:)
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
              (commit "main")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "13f6q0z4wc1is4b1vxvgzcgr2ahdsmqm36pkkfnqhvcadxikp0i4"))))
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
            "-DBUILD_TESTING:BOOL=OFF")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'enter-extension-dir
              (lambda _
                (chdir "myext"))))))
    (inputs
      (list slicer-5.8))
    (synopsis "MVox mesh generation Slicer extension")
    (description
     "A 3D Slicer loadable module extension providing MVox mesh generation.")
    (home-page "https://github.com/DavinhDang/guix-geng-project")
    (license license:asl2.0)))
