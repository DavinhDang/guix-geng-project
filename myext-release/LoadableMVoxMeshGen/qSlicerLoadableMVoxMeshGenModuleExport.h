/*=auto=========================================================================

 Portions (c) Copyright 2005 Brigham and Women's Hospital (BWH)
 All Rights Reserved.

 See COPYRIGHT.txt
 or http://www.slicer.org/copyright/copyright.txt for details.

 Program:   3D Slicer

=========================================================================auto=*/


// .NAME __qSlicerLoadableMVoxMeshGenModuleExport - manage Windows system differences
// .SECTION Description
// The __qSlicerLoadableMVoxMeshGenModuleExport captures some system differences between Unix
// and Windows operating systems.

#ifndef __qSlicerLoadableMVoxMeshGenModuleExport_h
#define __qSlicerLoadableMVoxMeshGenModuleExport_h

#if defined(WIN32) && !defined(qSlicerLoadableMVoxMeshGenModule_STATIC)
 #if defined(qSlicerLoadableMVoxMeshGenModule_EXPORTS)
  #define Q_SLICER_QTMODULES_LoadableMVoxMeshGen_EXPORT __declspec( dllexport )
 #else
  #define Q_SLICER_QTMODULES_LoadableMVoxMeshGen_EXPORT __declspec( dllimport )
 #endif
#else
 #define Q_SLICER_QTMODULES_LoadableMVoxMeshGen_EXPORT
#endif

#endif
