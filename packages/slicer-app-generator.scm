;; 
;; Copyright @ 2025 Oslo University Hospital
;;
;; Alternative approach: Package the template generator as a tool
;; Users can then generate their own custom apps and build them separately
;;

(define-module (guix-systole packages slicer-app-generator)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages version-control)
  #:use-module (guix build-system python)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix-systole packages slicer))

(define-public slicer-app-generator
  (package
    (name "slicer-app-generator")
    (version "2025.02.11")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/KitwareMedical/SlicerCustomAppTemplate")
             (commit "main"))) ;; Pin to specific commit for reproducibility
       (file-name (git-file-name name version))
       (sha256
        (base32 "0000000000000000000000000000000000000000000000000000")))) ;; Update hash
    (build-system python-build-system)
    (arguments
     (list
      #:tests? #f ;; No test suite in template repo
      #:phases
      #~(modify-phases %standard-phases
                       ;; This is just a template directory, not a Python package
                       (delete 'build)
                       (delete 'check)
                       (replace 'install
                                (lambda* (#:key outputs #:allow-other-keys)
                                         (let* ((out (assoc-ref outputs "out"))
                                                (share (string-append out "/share/slicer-templates"))
                                                (bin (string-append out "/bin")))
                                           ;; Install the template files
                                           (copy-recursively "." share)
                                           
                                           ;; Create a wrapper script to run cookiecutter with this template
                                           (mkdir-p bin)
                                           (call-with-output-file (string-append bin "/create-slicer-app")
                                                                  (lambda (port)
                                                                    (format port "#!~a/bin/bash
# Wrapper script to generate a custom Slicer application

if [ $# -eq 0 ]; then
    OUTPUT_DIR=\".\"
else
    OUTPUT_DIR=\"$1\"
fi

echo \"Generating custom Slicer application...\"
echo \"Template location: ~a\"
echo \"Output directory: $OUTPUT_DIR\"
echo \"\"

cd \"$OUTPUT_DIR\" || exit 1
~a/bin/cookiecutter ~a

echo \"\"
echo \"Custom Slicer application generated successfully!\"
echo \"\"
echo \"Next steps:\"
echo \"1. Review and customize the generated CMakeLists.txt\"
echo \"2. Add any custom modules to the Modules/ directory\"
echo \"3. Build the application using Guix or standard CMake\"
echo \"\"
echo \"For Guix packaging, see the documentation in:\"
echo \"~a/README.md\"
~%"
                                                                            #$(this-package-native-input "bash-minimal")
                                                                            share
                                                                            #$(this-package-input "python-cookiecutter")
                                                                            share
                                                                            share)))
                                           (chmod (string-append bin "/create-slicer-app") #o755)
                                           
                                           ;; Create a README with Guix-specific instructions
                                           (call-with-output-file (string-append share "/README-GUIX.md")
                                                                  (lambda (port)
                                                                    (display "# Building Custom Slicer Apps with Guix

## Quick Start

1. Generate your custom app:
   ```bash
   create-slicer-app /path/to/output
   ```

2. Follow the prompts to configure your app

3. Create a Guix package definition for your generated app
   (see example in share/slicer-templates/example-package.scm)

## Building the Generated App

The generated application will have its own CMakeLists.txt that expects
to use Slicer's superbuild. For Guix, you'll want to:

1. Set Slicer_SUPERBUILD=OFF
2. Point Slicer_DIR to your system Slicer installation
3. Use system libraries for all dependencies

See the example package definition for details.

## Requirements

Your custom app package will need these inputs:
- slicer-5.8 (from guix-systole)
- All standard Slicer dependencies
- Any additional dependencies your custom modules require

## Support

For template issues: https://github.com/KitwareMedical/SlicerCustomAppTemplate/issues
For Guix packaging help: Contact guix-systole maintainers
" port)))
                                           #t))))))
    (inputs
     (list python-cookiecutter
           python-jinja2-github))
    (propagated-inputs
     (list slicer-5.8)) ;; Make Slicer available for reference
    (native-inputs
     (list git)) ;; Needed by cookiecutter
    (synopsis "Template generator for custom 3D Slicer applications")
    (description
     "This package provides the SlicerCustomAppTemplate as a tool for generating
custom 3D Slicer applications.  It includes:

@itemize
@item The cookiecutter template for generating custom Slicer apps
@item A wrapper script (create-slicer-app) to simplify app generation
@item Documentation for packaging generated apps with Guix
@item Example Guix package definitions
@end itemize

After installation, run @code{create-slicer-app} to generate a new custom
Slicer application.  The generated application can then be packaged as a
separate Guix package.

Note: This package generates the template for custom apps.  To build and
install a specific custom Slicer application, you'll need to create a
separate package definition for that app.")
    (home-page "https://github.com/KitwareMedical/SlicerCustomAppTemplate")
    (license license:asl2.0)))
