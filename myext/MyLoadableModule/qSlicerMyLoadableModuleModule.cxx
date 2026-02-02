/*==============================================================================

  Program: 3D Slicer

  Portions (c) Copyright Brigham and Women's Hospital (BWH) All Rights Reserved.

  See COPYRIGHT.txt
  or http://www.slicer.org/copyright/copyright.txt for details.

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

==============================================================================*/

// MyLoadableModule Logic includes
#include <vtkSlicerMyLoadableModuleLogic.h>

// MyLoadableModule includes
#include "qSlicerMyLoadableModuleModule.h"
#include "qSlicerMyLoadableModuleModuleWidget.h"

//-----------------------------------------------------------------------------
class qSlicerMyLoadableModuleModulePrivate
{
public:
  qSlicerMyLoadableModuleModulePrivate();
};

//-----------------------------------------------------------------------------
// qSlicerMyLoadableModuleModulePrivate methods

//-----------------------------------------------------------------------------
qSlicerMyLoadableModuleModulePrivate::qSlicerMyLoadableModuleModulePrivate()
{
}

//-----------------------------------------------------------------------------
// qSlicerMyLoadableModuleModule methods

//-----------------------------------------------------------------------------
qSlicerMyLoadableModuleModule::qSlicerMyLoadableModuleModule(QObject* _parent)
  : Superclass(_parent)
  , d_ptr(new qSlicerMyLoadableModuleModulePrivate)
{
}

//-----------------------------------------------------------------------------
qSlicerMyLoadableModuleModule::~qSlicerMyLoadableModuleModule()
{
}

//-----------------------------------------------------------------------------
QString qSlicerMyLoadableModuleModule::helpText() const
{
  return "This is a loadable module that can be bundled in an extension";
}

//-----------------------------------------------------------------------------
QString qSlicerMyLoadableModuleModule::acknowledgementText() const
{
  return "This work was partially funded by NIH grant NXNNXXNNNNNN-NNXN";
}

//-----------------------------------------------------------------------------
QStringList qSlicerMyLoadableModuleModule::contributors() const
{
  QStringList moduleContributors;
  moduleContributors << QString("John Doe (AnyWare Corp.)");
  return moduleContributors;
}

//-----------------------------------------------------------------------------
QIcon qSlicerMyLoadableModuleModule::icon() const
{
  return QIcon(":/Icons/MyLoadableModule.png");
}

//-----------------------------------------------------------------------------
QStringList qSlicerMyLoadableModuleModule::categories() const
{
  return QStringList() << "Examples";
}

//-----------------------------------------------------------------------------
QStringList qSlicerMyLoadableModuleModule::dependencies() const
{
  return QStringList();
}

//-----------------------------------------------------------------------------
void qSlicerMyLoadableModuleModule::setup()
{
  this->Superclass::setup();
}

//-----------------------------------------------------------------------------
qSlicerAbstractModuleRepresentation* qSlicerMyLoadableModuleModule
::createWidgetRepresentation()
{
  return new qSlicerMyLoadableModuleModuleWidget;
}

//-----------------------------------------------------------------------------
vtkMRMLAbstractLogic* qSlicerMyLoadableModuleModule::createLogic()
{
  return vtkSlicerMyLoadableModuleLogic::New();
}
