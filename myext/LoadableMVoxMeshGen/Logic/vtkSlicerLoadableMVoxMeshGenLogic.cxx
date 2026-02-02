// LoadableMVoxMeshGen Logic includes
#include "vtkSlicerLoadableMVoxMeshGenLogic.h"

// MRML includes
#include <vtkMRMLScene.h>
#include <vtkMRMLScalarVolumeNode.h>
#include <vtkMRMLLabelMapVolumeNode.h>
#include <vtkMRMLStorageNode.h>

// VTK includes
#include <vtkIntArray.h>
#include <vtkNew.h>
#include <vtkObjectFactory.h>

// STD includes
#include <cassert>
#include <sstream>

// Process execution
#ifdef _WIN32
#include <windows.h>
#else
#include <cstdlib>
#endif

//----------------------------------------------------------------------------
vtkStandardNewMacro(vtkSlicerLoadableMVoxMeshGenLogic);

//----------------------------------------------------------------------------
vtkSlicerLoadableMVoxMeshGenLogic::vtkSlicerLoadableMVoxMeshGenLogic()
{
}

//----------------------------------------------------------------------------
vtkSlicerLoadableMVoxMeshGenLogic::~vtkSlicerLoadableMVoxMeshGenLogic()
{
}

//----------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic::PrintSelf(ostream& os, vtkIndent indent)
{
  this->Superclass::PrintSelf(os, indent);
}

//---------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic::SetMRMLSceneInternal(vtkMRMLScene * newScene)
{
  vtkNew<vtkIntArray> events;
  events->InsertNextValue(vtkMRMLScene::NodeAddedEvent);
  events->InsertNextValue(vtkMRMLScene::NodeRemovedEvent);
  events->InsertNextValue(vtkMRMLScene::EndBatchProcessEvent);
  this->SetAndObserveMRMLSceneEventsInternal(newScene, events.GetPointer());
}

//-----------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic::RegisterNodes()
{
  assert(this->GetMRMLScene() != 0);
}

//---------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic::UpdateFromMRMLScene()
{
  assert(this->GetMRMLScene() != 0);
}

//---------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic
::OnMRMLSceneNodeAdded(vtkMRMLNode* vtkNotUsed(node))
{
}

//---------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic
::OnMRMLSceneNodeRemoved(vtkMRMLNode* vtkNotUsed(node))
{
}

//----------------------------------------------------------------------------
void vtkSlicerLoadableMVoxMeshGenLogic::RunMVox(
  const std::string& meshOutputPath,
  const std::string& tensorsOutputPath,
  vtkMRMLNode* masksNode,
  vtkMRMLNode* attributesNode,
  vtkMRMLNode* tensorsNode,
  bool symmetric,
  int nx, int ny, int nz,
  int vx, int vy, int vz)
{
  // Build command
  std::stringstream cmd;
  cmd << "mvox";

  // Add output files
  if (!meshOutputPath.empty())
  {
    cmd << " -omesh \"" << meshOutputPath << "\"";
  }
  
  if (!tensorsOutputPath.empty())
  {
    cmd << " -otensor \"" << tensorsOutputPath << "\"";
  }

  // Add input files
  if (masksNode)
  {
    vtkMRMLStorageNode* storageNode = masksNode->GetStorageNode();
    if (storageNode && storageNode->GetFileName())
    {
      cmd << " -imask \"" << storageNode->GetFileName() << "\"";
    }
  }

  if (attributesNode)
  {
    vtkMRMLStorageNode* storageNode = attributesNode->GetStorageNode();
    if (storageNode && storageNode->GetFileName())
    {
      cmd << " -iattr \"" << storageNode->GetFileName() << "\"";
    }
  }

  if (tensorsNode)
  {
    vtkMRMLStorageNode* storageNode = tensorsNode->GetStorageNode();
    if (storageNode && storageNode->GetFileName())
    {
      cmd << " -itensor \"" << storageNode->GetFileName() << "\"";
    }
  }

  // Add boolean flag
  if (symmetric)
  {
    cmd << " -sym";
  }

  // Add advanced parameters
  if (nx > 0)
  {
    cmd << " -nx " << nx;
  }
  if (ny > 0)
  {
    cmd << " -ny " << ny;
  }
  if (nz > 0)
  {
    cmd << " -nz " << nz;
  }
  if (vx > 0)
  {
    cmd << " -vx " << vx;
  }
  if (vy > 0)
  {
    cmd << " -vy " << vy;
  }
  if (vz > 0)
  {
    cmd << " -vz " << vz;
  }

  vtkDebugMacro("Running command: " << cmd.str());

  // Execute command
#ifdef _WIN32
  system(cmd.str().c_str());
#else
  int result = system(cmd.str().c_str());
  if (result != 0)
  {
    vtkErrorMacro("MVox command failed with error code: " << result);
  }
#endif
}
