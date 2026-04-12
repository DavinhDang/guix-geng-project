;;
;; Updated slicer-custom-app-template.scm compatible with slicer.scm
;;

(define-module (guix-geng-project packages slicer-custom-app-template)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages geo)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages tbb)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages)
  #:use-module (guix build-system cmake)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (systole packages slicer)     ; Updated namespace
  #:use-module (systole packages ctk)
  #:use-module (systole packages itk)
  #:use-module (systole packages libarchive)
  #:use-module (systole packages maths)
  #:use-module (systole packages pythonqt)
  #:use-module (systole packages qrestapi)
  #:use-module (systole packages teem)
  #:use-module (systole packages vtk))

(define-public slicer-custom-app-template
  (package
    (name "slicer-custom-app-template")
    (version "2025.02.11")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/DavinhDang/SlicerCustomAppTemplate")
             (commit "main"))) ; Pin to specific commit in production
       (file-name (git-file-name name version))
       (sha256
        (base32 "0wizz72x1jlg5dri1ih310q1sgf1n08fx4gx4y5ns6wyh2mry8j5"))
       ;; Note: You may need patches for building against system Slicer
       (patches (search-patches
                 ;; Add any patches you need here
                 ))))
    (build-system cmake-build-system)
    (arguments
     (list #:tests? #f  ; Disable tests (requires GUI)
           #:validate-runpath? #f
           #:configure-flags
           #~(list
              ;; Compiler configuration
              "-DCMAKE_BUILD_TYPE:STRING=Release"
              "-DCMAKE_CXX_COMPILER:STRING=g++"
              "-DCMAKE_C_COMPILER:STRING=gcc"
              "-DCMAKE_CXX_STANDARD:STRING=17"

              ;; Compiler flags
              "-DCMAKE_EXE_LINKER_FLAGS=-pthread"
              
              ;; CRITICAL: Disable superbuild, use system Slicer
              "-DSlicer_SUPERBUILD:BOOL=OFF"
              
              ;; Point to the modular slicer-5.8 package
              (string-append "-DSlicer_DIR:PATH="
                            #$(this-package-input "slicer-5.8")
                            "/lib/cmake/Slicer-5.8")
              
              ;; Testing disabled
              "-DBUILD_TESTING:BOOL=OFF"
              "-DBUILD_SHARED_LIBS:BOOL=ON"
              
              ;; Define extensions directory basename
              "-DSlicer_EXTENSIONS_DIRBASENAME:STRING=Extensions"
              
              ;; Extension manager and modules
              "-DSlicer_BUILD_EXTENSIONMANAGER_SUPPORT:BOOL=OFF"
              "-DSlicer_DONT_USE_EXTENSION:BOOL=ON"
              "-DSlicer_REQUIRED_QT_VERSION:STRING=5"
              
              ;; CLI modules (optional)
              "-DSlicer_BUILD_CLI:BOOL=OFF"
              "-DSlicer_BUILD_CLI_SUPPORT:BOOL=OFF"

              ;; Qt loadable modules
              "-DSlicer_BUILD_QTLOADABLEMODULES:BOOL=ON"
              "-DSlicer_BUILD_QTSCRIPTEDMODULES:BOOL=OFF"
              "-DSlicer_BUILD_QT_DESIGNER_PLUGINS:BOOL=OFF"
              "-DSlicer_USE_QtTesting:BOOL=OFF"
              "-DSlicer_USE_SlicerITK:BOOL=ON"
              "-DSlicer_USE_CTKAPPLAUNCHER:BOOL=ON"
              "-DSlicer_BUILD_WEBENGINE_SUPPORT:BOOL=OFF"
              
              ;; Qt5 path
              (string-append "-DQt5_DIR:PATH="
                            #$(this-package-input "qtbase")
                            "/lib/cmake/Qt5")
                            
              ;; Slicer sources path (avoids FetchContent network call)
              (string-append "-Dslicersources_SOURCE_DIR="
               #$(this-package-input "slicer-5.8")
               "/lib/Slicer-5.8")
              
              ;; VTK configuration
              "-DSlicer_VTK_VERSION_MAJOR:STRING=9"
              "-DSlicer_BUILD_vtkAddon:BOOL=OFF"

              ;; Development files
              "-DSlicer_INSTALL_DEVELOPMENT:BOOL=ON"
              "-DSlicer_USE_TBB:BOOL=ON"

              ;; DICOM support (disabled by default)
              "-DSlicer_BUILD_DICOM_SUPPORT:BOOL=OFF"

              ;; Python (disabled for minimal build)
              "-DVTK_WRAP_PYTHON:BOOL=OFF"
              "-DSlicer_USE_PYTHONQT:BOOL=OFF"
              "-DSlicer_USE_SYSTEM_python:BOOL=OFF"

              ;; Use system libraries (must match Slicer's configuration)
              "-DSlicer_USE_SYSTEM_bzip2:BOOL=ON"
              "-DSlicer_USE_SYSTEM_CTK:BOOL=ON"
              "-DSlicer_USE_SYSTEM_TBB:BOOL=ON"
              "-DSlicer_USE_SYSTEM_teem:BOOL=ON"
              "-DSlicer_USE_SYSTEM_QT:BOOL=ON"
              "-DSlicer_USE_SYSTEM_curl:BOOL=ON"
              "-DSlicer_USE_SYSTEM_DCMTK:BOOL=ON"
              "-DSlicer_USE_SYSTEM_ITK:BOOL=ON"
              "-DSlicer_USE_SYSTEM_LibArchive:BOOL=ON"
              "-DSlicer_USE_SYSTEM_LibFFI:BOOL=ON"
              "-DSlicer_USE_SYSTEM_LZMA:BOOL=ON"
              "-DSlicer_USE_SYSTEM_RapidJSON:BOOL=ON"
              "-DSlicer_USE_SYSTEM_sqlite:BOOL=ON"
              "-DSlicer_USE_SYSTEM_VTK:BOOL=ON"
              "-DSlicer_USE_SYSTEM_zlib:BOOL=ON"

              ;; Version info
              "-DSlicer_WC_LAST_CHANGED_DATE:STRING=2025-2-12 10:00:00 +0000")
           
           #:out-of-source? #t
           
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'configure 'set-cmake-paths
                 (lambda* (#:key inputs #:allow-other-keys)
                   ;; Make dependencies discoverable by CMake
                   (setenv "CMAKE_PREFIX_PATH"
                          (string-append 
                            (assoc-ref inputs "vtkaddon") "/lib/cmake:"
                            (assoc-ref inputs "slicer-5.8") "/lib/cmake:"
                            (assoc-ref inputs "qtbase") "/lib/cmake:"
                            (or (getenv "CMAKE_PREFIX_PATH") "")))
                   
                   ;; Also set Qt5_DIR explicitly
                   (setenv "Qt5_DIR"
                          (string-append (assoc-ref inputs "qtbase")
                                        "/lib/cmake/Qt5"))
                   #t))
               
               ;; Patch CMakeLists.txt to ensure EXTENSIONS_DIRBASENAME is defined
               (add-after 'unpack 'fix-extensions-dirbasename
                 (lambda _
                   (substitute* "CMakeLists.txt"
                     (("set\\(extension_defaults_file.*")
                      (string-append
                       "set(extension_defaults_file \"${CMAKE_CURRENT_SOURCE_DIR}/SlicerDefaultExtensions.cmake\")
if(EXISTS \"${extension_defaults_file}\")
  include(\"${extension_defaults_file}\")
endif()

# Ensure Slicer_EXTENSIONS_DIRBASENAME is defined for non-superbuild
if(NOT DEFINED Slicer_EXTENSIONS_DIRBASENAME)
  set(Slicer_EXTENSIONS_DIRBASENAME \"Extensions\")
endif()
")))
                   #t))

               (add-after 'install 'wrap
                 (lambda* (#:key outputs #:allow-other-keys)
                   (let* ((out (assoc-ref outputs "out"))
                          ;; App name depends on cookiecutter template
                          (app-launcher (string-append out "/bin/SlicerCustomAppTemplate"))
                          (app-wrapper (string-append out "/bin/SlicerCustomAppTemplate-real")))
                     ;; Only wrap if launcher exists
                     (when (file-exists? app-launcher)
                       ;; Rename original launcher
                       (rename-file app-launcher app-wrapper)
                       ;; Create new wrapper
                       (call-with-output-file app-launcher
                         (lambda (port)
                           (format port "#!/bin/bash
export LD_LIBRARY_PATH=\"~a/lib/Slicer-5.8/qt-loadable-modules${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"
export QT_PLUGIN_PATH=\"~a/lib/qt5/plugins${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}\"
exec ~a \"$@\"
"
                                   (assoc-ref outputs "slicer-5.8")
                                   (assoc-ref outputs "qtbase")
                                   app-wrapper)))
                       ;; Make wrapper executable
                       (chmod app-launcher #o755))
                     #t))))))
    
    (inputs
     (list libxt
           eigen
           expat
           openssl-3.0
           git
           hdf5-1.10
           libffi
           libjpeg-turbo
           libxinerama
           mesa
           rapidjson
           tbb

           ;; Qt5
           qtbase-5
           qtmultimedia-5
           qtxmlpatterns-5
           qtdeclarative-5
           qtsvg-5
           qtx11extras
           qtwebchannel-5
           qttools-5

           ;; VTK
           vtk-slicer
           double-conversion
           freetype
           gl2ps
           glew
           jsoncpp
           libharu
           libtheora
           libxml++
           lz4
           mpich
           netcdf
           proj

           ;; Slicer and related modules
           ;; KEY CHANGE: Use slicer-5.8 from the modular package
           slicer-5.8
           ctk
           ctkapplauncher
           itk-slicer
           libarchive-slicer
           teem-slicer
           vtkaddon
           qrestapi))
    
    (native-inputs (list pkg-config))
    
    (synopsis "Template for creating custom 3D Slicer applications")
    (description
     "SlicerCustomAppTemplate is a cookiecutter-based template for creating
custom 3D Slicer applications.  This package builds the custom application
using the system-provided Slicer installation.

This package is configured to build against the modular slicer-5.8 package,
which provides better support for custom application development with enhanced
CMake configuration and development file installation.")
    
    (home-page "https://github.com/DavinhDang/SlicerCustomAppTemplate")
    (license license:asl2.0)))
