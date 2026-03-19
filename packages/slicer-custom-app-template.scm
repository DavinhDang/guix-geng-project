;; 
;; Copyright @ 2025 Oslo University Hospital
;;
;; This file is part of SystoleOS.
;;
;; SystoleOS is free software: you can redistribute it and/or modify it under the 
;; terms of the GNU General Public License as published by the Free Software 
;; Foundation, either version 3 of the License, or (at your option) any later version.
;;
;; SystoleOS is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
;; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
;; PURPOSE. See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along 
;; with SystoleOS. If not, see <https://www.gnu.org/licenses/>.
;; 

(define-module (guix-systole packages slicer-custom-app-template)
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
  #:use-module (guix build-system qt)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix-systole packages ctk)
  #:use-module (guix-systole packages itk)
  #:use-module (guix-systole packages libarchive)
  #:use-module (guix-systole packages maths)
  #:use-module (guix-systole packages qrestapi)
  #:use-module (guix-systole packages slicer)
  #:use-module (guix-systole packages teem)
  #:use-module (guix-systole packages vtk)
  #:use-module (guix-systole packages)
  )

(define-public slicer-custom-app-template
  (package
    (name "slicer-custom-app")
    (version "2025.02.11") ;; Using date-based versioning since no formal releases
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/KitwareMedical/SlicerCustomAppTemplate")
             (commit "main"))) ;; Pin to a specific commit in production
       (file-name (git-file-name name version))
       (sha256
        (base32 "0n9brxyil23vr05x2l1scv8n5djhh6cvf3clx9kz156nlp1jway4")))) ;; Update with actual hash
    (build-system cmake-build-system)
    (arguments
     (list #:tests? #f
           #:validate-runpath? #f
           #:configure-flags
           #~(list
              ;; Compiler info
              "-DCMAKE_BUILD_TYPE:STRING=Release"
              "-DCMAKE_CXX_COMPILER:STRING=g++"
              "-DCMAKE_C_COMPILER:STRING=gcc"
              "-DCMAKE_CXX_STANDARD:STRING=17"

              ;; Compiler flags
              "-DCMAKE_EXE_LINKER_FLAGS=-pthread"
              
              ;; Use system Slicer instead of superbuild
              "-DSlicer_SUPERBUILD:BOOL=OFF"
              "-DBUILD_TESTING:BOOL=OFF"
              "-DBUILD_SHARED_LIBS:BOOL=ON"
              
              ;; Custom app specific settings
              (string-append "-DSlicer_DIR:PATH="
                             #$(this-package-input "slicer-5.8")
                             "/lib/cmake/Slicer-5.8")
              
              ;; Extension manager and modules
              "-DSlicer_BUILD_EXTENSIONMANAGER_SUPPORT:BOOL=OFF"
              "-DSlicer_DONT_USE_EXTENSION:BOOL=ON"
              "-DSlicer_REQUIRED_QT_VERSION:STRING=5"
              
              ;; CLI
              "-DSlicer_BUILD_CLI:BOOL=OFF"
              "-DSlicer_BUILD_CLI_SUPPORT:BOOL=OFF"

              ;; QT
              "-DSlicer_BUILD_QTLOADABLEMODULES:BOOL=ON"
              "-DSlicer_BUILD_QTSCRIPTEDMODULES:BOOL=OFF"
              "-DSlicer_BUILD_QT_DESIGNER_PLUGINS:BOOL=OFF"
              "-DSlicer_USE_QtTesting:BOOL=OFF"
              "-DSlicer_USE_SlicerITK:BOOL=ON"
              "-DSlicer_USE_CTKAPPLAUNCHER:BOOL=ON"
              "-DSlicer_BUILD_WEBENGINE_SUPPORT:BOOL=OFF"
              (string-append "-DQt5_DIR:PATH="
                             #$(this-package-input "qtbase"))
              "-DSlicer_VTK_VERSION_MAJOR:STRING=9"
              "-DSlicer_BUILD_vtkAddon:BOOL=OFF"

              "-DSlicer_INSTALL_DEVELOPMENT:BOOL=ON"
              "-DSlicer_USE_TBB:BOOL=ON"

              ;; DICOM support (disabled as in base slicer)
              "-DSlicer_BUILD_DICOM_SUPPORT:BOOL=OFF"

              ;; Python
              "-DVTK_WRAP_PYTHON:BOOL=OFF"
              "-DSlicer_USE_PYTHONQT:BOOL=OFF"
              "-DSlicer_USE_SYSTEM_python:BOOL=OFF"

              ;; Use system libraries
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

              ;; Version info hack
              "-DSlicer_WC_LAST_CHANGED_DATE:STRING=2025-3-2 19:58:36 -0500")
           #:out-of-source? #t
           #:phases
           #~(modify-phases %standard-phases
                            (add-before 'configure 'set-cmake-paths
                                        (lambda* (#:key inputs #:allow-other-keys)
                                          ;; Make dependencies discoverable by CMake
                                          (setenv "CMAKE_PREFIX_PATH"
                                                  (string-append (assoc-ref inputs "vtkaddon")
                                                                 "/lib/cmake:"
                                                                 (assoc-ref inputs "slicer-5.8")
                                                                 "/lib/cmake:"
                                                                 (or (getenv "CMAKE_PREFIX_PATH")
                                                                     ""))) #t))

                            (add-after 'install 'wrap
                                       (lambda* (#:key outputs #:allow-other-keys)
                                                (let* ((out (assoc-ref outputs "out"))
                                                       (app-launcher (string-append out "/CustomApp"))
                                                       (app-wrapper (string-append out "/CustomApp-wrapper")))
                                                  ;; Create wrapper for the custom app
                                                  (when (file-exists? app-launcher)
                                                    (call-with-output-file app-wrapper
                                                                           (lambda (port)
                                                                             (format port
"export LD_LIBRARY_PATH=\"$HOME/.guix-profile/lib/Slicer-5.8/SlicerModules${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"
exec ~a --additional-module-path \"$HOME/.guix-profile/lib/Slicer-5.8/SlicerModules\" \"$@\"~%"
                                                                                     app-launcher)))
                                                    ;; Make wrapper executable
                                                    (chmod app-wrapper #o755)
                                                    #t))))
                            
                            (add-after 'wrap 'symlink-app-launcher
                                       (lambda* (#:key outputs #:allow-other-keys)
                                                (let* ((out (assoc-ref outputs "out"))
                                                       (wrapper (string-append out "/CustomApp-wrapper"))
                                                       (bin-link (string-append out "/bin/CustomApp")))
                                                  (when (file-exists? wrapper)
                                                    (symlink wrapper bin-link))
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
           mesa ;libGL equivalent
           rapidjson
           tbb

           ;; QT5
           qtbase-5
           qtmultimedia-5
           qtxmlpatterns
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
custom 3D Slicer applications.  It allows developers to:
@itemize
@item Create branded custom Slicer applications
@item Customize the application name, logo, and appearance
@item Select which built-in modules to include
@item Add custom modules specific to their application
@item Set default home modules and favorite modules
@end itemize

The template uses the Slicer superbuild system to download and compile all
dependencies, then builds the custom application on top of Slicer.  This
package is configured to use the system-provided Slicer installation instead
of downloading and building Slicer from scratch.")
    (home-page "https://github.com/KitwareMedical/SlicerCustomAppTemplate")
    (license license:asl2.0)))
