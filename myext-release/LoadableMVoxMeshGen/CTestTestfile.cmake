# CMake generated Testfile for 
# Source directory: /home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen
# Build directory: /home/davinh/guix-geng-project/myext-release/LoadableMVoxMeshGen
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test([=[qSlicerLoadableMVoxMeshGenModuleGenericTest]=] "/home/davinh/Slicer-SuperBuild-Debug/Slicer-build/Slicer" "--launcher-additional-settings" "/home/davinh/guix-geng-project/myext-release/AdditionalLauncherSettings.ini" "--launch" "/home/davinh/guix-geng-project/myext-release/bin/qSlicerLoadableMVoxMeshGenModuleGenericCxxTests" "qSlicerLoadableMVoxMeshGenModuleGenericTest")
set_tests_properties([=[qSlicerLoadableMVoxMeshGenModuleGenericTest]=] PROPERTIES  LABELS "qSlicerLoadableMVoxMeshGenModule" _BACKTRACE_TRIPLES "/home/davinh/Slicer/CMake/SlicerMacroBuildLoadableModule.cmake;292;add_test;/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen/CMakeLists.txt;46;slicerMacroBuildLoadableModule;/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen/CMakeLists.txt;0;")
add_test([=[qSlicerLoadableMVoxMeshGenModuleWidgetGenericTest]=] "/home/davinh/Slicer-SuperBuild-Debug/Slicer-build/Slicer" "--launcher-additional-settings" "/home/davinh/guix-geng-project/myext-release/AdditionalLauncherSettings.ini" "--launch" "/home/davinh/guix-geng-project/myext-release/bin/qSlicerLoadableMVoxMeshGenModuleGenericCxxTests" "qSlicerLoadableMVoxMeshGenModuleWidgetGenericTest")
set_tests_properties([=[qSlicerLoadableMVoxMeshGenModuleWidgetGenericTest]=] PROPERTIES  LABELS "qSlicerLoadableMVoxMeshGenModule" _BACKTRACE_TRIPLES "/home/davinh/Slicer/CMake/SlicerMacroBuildLoadableModule.cmake;292;add_test;/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen/CMakeLists.txt;46;slicerMacroBuildLoadableModule;/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen/CMakeLists.txt;0;")
subdirs("Logic")
subdirs("Testing")
