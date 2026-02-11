#
# This file makes available modules implemented in this extension to other extensions.
#

set(myext_SOURCE_DIR "/home/davinh/guix-geng-project/myext")

set(myext_LIBRARY_PATHS_LAUNCHER_BUILD "/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/cli-modules/${CMAKE_CFG_INTDIR};/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/qt-loadable-modules/${CMAKE_CFG_INTDIR}")
set(myext_PATHS_LAUNCHER_BUILD "/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/cli-modules/${CMAKE_CFG_INTDIR};/home/davinh/guix-geng-project/myext-release/bin/${CMAKE_CFG_INTDIR}")
set(myext_ENVVARS_LAUNCHER_BUILD "")
set(myext_PYTHONPATH_LAUNCHER_BUILD "/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/qt-scripted-modules;/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/qt-loadable-modules/${CMAKE_CFG_INTDIR};/home/davinh/guix-geng-project/myext-release/lib/Slicer-5.8/qt-loadable-modules/Python")



# --------------------------------------------------------------------------
# Include directories

# Extension include directories for module

set(qSlicerLoadableMVoxMeshGenModule_INCLUDE_DIRS
  "/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen;/home/davinh/guix-geng-project/myext-release/LoadableMVoxMeshGen")

# Extension include directories for module logic

set(vtkSlicerLoadableMVoxMeshGenModuleLogic_INCLUDE_DIRS
  "/home/davinh/guix-geng-project/myext/LoadableMVoxMeshGen/Logic;/home/davinh/guix-geng-project/myext-release/LoadableMVoxMeshGen/Logic")

# Extension include directories for module mrml


# Extension include directories for module Widget


# Extension VTK wrap hierarchy files


# Extension Module logic include file directories.
set(myext_ModuleLogic_INCLUDE_DIRS "${vtkSlicerLoadableMVoxMeshGenModuleLogic_INCLUDE_DIRS}"
  CACHE INTERNAL "Extension Module logic includes" FORCE)

# Extension Module MRML include file directories.
set(myext_ModuleMRML_INCLUDE_DIRS ""
  CACHE INTERNAL "Extension Module MRML includes" FORCE)

# Extension Module Widgets include file directories.
set(myext_ModuleWidgets_INCLUDE_DIRS ""
  CACHE INTERNAL "Extension Module widgets includes" FORCE)

# --------------------------------------------------------------------------
# Target definitions

if(EXISTS "/home/davinh/guix-geng-project/myext-release/./myextTargets.cmake")
  include("/home/davinh/guix-geng-project/myext-release/./myextTargets.cmake")
endif()
