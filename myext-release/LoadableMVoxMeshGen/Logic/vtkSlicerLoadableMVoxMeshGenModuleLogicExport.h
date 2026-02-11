/*=auto=========================================================================

 Portions (c) Copyright 2005 Brigham and Women's Hospital (BWH)
 All Rights Reserved.

 See COPYRIGHT.txt
 or http://www.slicer.org/copyright/copyright.txt for details.

 Program:   3D Slicer

=========================================================================auto=*/


// .NAME __vtkSlicerLoadableMVoxMeshGenModuleLogicExport - manage Windows system differences
// .SECTION Description
// The __vtkSlicerLoadableMVoxMeshGenModuleLogicExport captures some system differences between Unix
// and Windows operating systems.

#ifndef __vtkSlicerLoadableMVoxMeshGenModuleLogicExport_h
#define __vtkSlicerLoadableMVoxMeshGenModuleLogicExport_h

#if defined(WIN32) && !defined(vtkSlicerLoadableMVoxMeshGenModuleLogic_STATIC)
 #if defined(vtkSlicerLoadableMVoxMeshGenModuleLogic_EXPORTS)
  #define VTK_SLICER_LOADABLEMVOXMESHGEN_MODULE_LOGIC_EXPORT __declspec( dllexport )
 #else
  #define VTK_SLICER_LOADABLEMVOXMESHGEN_MODULE_LOGIC_EXPORT __declspec( dllimport )
 #endif
#else
 #define VTK_SLICER_LOADABLEMVOXMESHGEN_MODULE_LOGIC_EXPORT
#endif

#endif
