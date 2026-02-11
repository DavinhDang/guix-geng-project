// Qt includes
#include <QtPlugin>

// LoadableMVoxMeshGen Logic includes
#include <vtkSlicerLoadableMVoxMeshGenLogic.h>

// LoadableMVoxMeshGen includes
#include "qSlicerLoadableMVoxMeshGenModule.h"
#include "qSlicerLoadableMVoxMeshGenModuleWidget.h"

//-----------------------------------------------------------------------------
class qSlicerLoadableMVoxMeshGenModulePrivate
{
public:
  qSlicerLoadableMVoxMeshGenModulePrivate();
};

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModulePrivate::qSlicerLoadableMVoxMeshGenModulePrivate()
{
}

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModule::qSlicerLoadableMVoxMeshGenModule(QObject* _parent)
  : Superclass(_parent)
  , d_ptr(new qSlicerLoadableMVoxMeshGenModulePrivate)
{
}

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModule::~qSlicerLoadableMVoxMeshGenModule()
{
}

//-----------------------------------------------------------------------------
QString qSlicerLoadableMVoxMeshGenModule::helpText() const
{
  return "This module creates hexahedral meshes using MVox. "
         "For more information see: "
         "https://github.com/SlicerCBM/SlicerCBM/tree/master/LoadableMVoxMeshGen";
}

//-----------------------------------------------------------------------------
QString qSlicerLoadableMVoxMeshGenModule::acknowledgementText() const
{
  return "";
}

//-----------------------------------------------------------------------------
QStringList qSlicerLoadableMVoxMeshGenModule::contributors() const
{
  QStringList moduleContributors;
  moduleContributors << QString("Benjamin Zwick");
  return moduleContributors;
}

//-----------------------------------------------------------------------------
QIcon qSlicerLoadableMVoxMeshGenModule::icon() const
{
  return QIcon(":/Icons/LoadableMVoxMeshGen.png");
}

//-----------------------------------------------------------------------------
QStringList qSlicerLoadableMVoxMeshGenModule::categories() const
{
  return QStringList() << "CBM.Mesh/Grid";
}

//-----------------------------------------------------------------------------
QStringList qSlicerLoadableMVoxMeshGenModule::dependencies() const
{
  return QStringList();
}

//-----------------------------------------------------------------------------
void qSlicerLoadableMVoxMeshGenModule::setup()
{
  this->Superclass::setup();
}

//-----------------------------------------------------------------------------
qSlicerAbstractModuleRepresentation* qSlicerLoadableMVoxMeshGenModule
::createWidgetRepresentation()
{
  return new qSlicerLoadableMVoxMeshGenModuleWidget;
}

//-----------------------------------------------------------------------------
vtkMRMLAbstractLogic* qSlicerLoadableMVoxMeshGenModule::createLogic()
{
  return vtkSlicerLoadableMVoxMeshGenLogic::New();
}
