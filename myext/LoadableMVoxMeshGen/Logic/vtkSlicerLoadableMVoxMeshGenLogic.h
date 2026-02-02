#ifndef __vtkSlicerLoadableMVoxMeshGenLogic_h
#define __vtkSlicerLoadableMVoxMeshGenLogic_h

// Slicer includes
#include "vtkSlicerModuleLogic.h"

// MRML includes
#include <vtkMRMLNode.h>

// STD includes
#include <string>

#include "vtkSlicerLoadableMVoxMeshGenModuleLogicExport.h"

class VTK_SLICER_LoadableMVoxMeshGen_MODULE_LOGIC_EXPORT vtkSlicerLoadableMVoxMeshGenLogic :
  public vtkSlicerModuleLogic
{
public:

  static vtkSlicerLoadableMVoxMeshGenLogic *New();
  vtkTypeMacro(vtkSlicerLoadableMVoxMeshGenLogic, vtkSlicerModuleLogic);
  void PrintSelf(ostream& os, vtkIndent indent);

  /// Run MVox mesh generator
  void RunMVox(
    const std::string& meshOutputPath,
    const std::string& tensorsOutputPath,
    vtkMRMLNode* masksNode,
    vtkMRMLNode* attributesNode,
    vtkMRMLNode* tensorsNode,
    bool symmetric,
    int nx, int ny, int nz,
    int vx, int vy, int vz
  );

protected:
  vtkSlicerLoadableMVoxMeshGenLogic();
  virtual ~vtkSlicerLoadableMVoxMeshGenLogic();

  virtual void SetMRMLSceneInternal(vtkMRMLScene* newScene);
  /// Register MRML Node classes to Scene. Gets called automatically when the MRMLScene is attached to this logic class.
  virtual void RegisterNodes();
  virtual void UpdateFromMRMLScene();
  virtual void OnMRMLSceneNodeAdded(vtkMRMLNode* node);
  virtual void OnMRMLSceneNodeRemoved(vtkMRMLNode* node);

private:

  vtkSlicerLoadableMVoxMeshGenLogic(const vtkSlicerLoadableMVoxMeshGenLogic&); // Not implemented
  void operator=(const vtkSlicerLoadableMVoxMeshGenLogic&); // Not implemented
};

#endif
