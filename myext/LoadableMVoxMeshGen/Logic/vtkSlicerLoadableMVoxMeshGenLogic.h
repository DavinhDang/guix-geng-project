#ifndef __vtkSlicerLoadableMVoxMeshGenLogic_h
#define __vtkSlicerLoadableMVoxMeshGenLogic_h

// Slicer includes
#include "vtkSlicerModuleLogic.h"

// MRML includes

// STD includes
#include <string>

#include "vtkSlicerLoadableMVoxMeshGenModuleLogicExport.h"

/// \ingroup Slicer_QtModules_LoadableMVoxMeshGen
class VTK_SLICER_LOADABLEMVOXMESHGEN_MODULE_LOGIC_EXPORT vtkSlicerLoadableMVoxMeshGenLogic
  : public vtkSlicerModuleLogic
{
public:

  static vtkSlicerLoadableMVoxMeshGenLogic *New();
  vtkTypeMacro(vtkSlicerLoadableMVoxMeshGenLogic, vtkSlicerModuleLogic);
  void PrintSelf(ostream& os, vtkIndent indent) override;

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
  ~vtkSlicerLoadableMVoxMeshGenLogic() override;

  void SetMRMLSceneInternal(vtkMRMLScene* newScene) override;
  /// Register MRML Node classes to Scene. Gets called automatically when the MRMLScene is attached to this logic class.
  void RegisterNodes() override;
  void UpdateFromMRMLScene() override;
  void OnMRMLSceneNodeAdded(vtkMRMLNode* node) override;
  void OnMRMLSceneNodeRemoved(vtkMRMLNode* node) override;

private:

  vtkSlicerLoadableMVoxMeshGenLogic(const vtkSlicerLoadableMVoxMeshGenLogic&) = delete;
  void operator=(const vtkSlicerLoadableMVoxMeshGenLogic&) = delete;
};

#endif
