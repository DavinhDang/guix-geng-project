// Qt includes
#include <QDebug>
#include <QPushButton>

// Slicer includes
#include "qSlicerLoadableMVoxMeshGenModuleWidget.h"
#include "ui_qSlicerLoadableMVoxMeshGenModuleWidget.h"

// Logic includes
#include "vtkSlicerLoadableMVoxMeshGenLogic.h"

// MRML includes
#include <vtkMRMLScene.h>
#include <vtkMRMLScalarVolumeNode.h>
#include <vtkMRMLLabelMapVolumeNode.h>

//-----------------------------------------------------------------------------
class qSlicerLoadableMVoxMeshGenModuleWidgetPrivate: public Ui_qSlicerLoadableMVoxMeshGenModuleWidget
{
public:
  qSlicerLoadableMVoxMeshGenModuleWidgetPrivate();
};

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModuleWidgetPrivate::qSlicerLoadableMVoxMeshGenModuleWidgetPrivate()
{
}

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModuleWidget::qSlicerLoadableMVoxMeshGenModuleWidget(QWidget* _parent)
  : Superclass( _parent )
  , d_ptr( new qSlicerLoadableMVoxMeshGenModuleWidgetPrivate )
{
}

//-----------------------------------------------------------------------------
qSlicerLoadableMVoxMeshGenModuleWidget::~qSlicerLoadableMVoxMeshGenModuleWidget()
{
}

//-----------------------------------------------------------------------------
void qSlicerLoadableMVoxMeshGenModuleWidget::setup()
{
  Q_D(qSlicerLoadableMVoxMeshGenModuleWidget);
  d->setupUi(this);
  this->Superclass::setup();

  d->MasksInputSelector->setMRMLScene(this->mrmlScene());
  d->AttributesInputSelector->setMRMLScene(this->mrmlScene());
  d->TensorsInputSelector->setMRMLScene(this->mrmlScene());

  // Connect Apply button
  connect(d->ApplyButton, SIGNAL(clicked()),
          this, SLOT(onApplyButtonClicked()));
}

//-----------------------------------------------------------------------------
void qSlicerLoadableMVoxMeshGenModuleWidget::setMRMLScene(vtkMRMLScene* scene)
{
  Q_D(qSlicerLoadableMVoxMeshGenModuleWidget);
  this->Superclass::setMRMLScene(scene);
  d->MasksInputSelector->setMRMLScene(scene);
  d->AttributesInputSelector->setMRMLScene(scene);
  d->TensorsInputSelector->setMRMLScene(scene);
}

//-----------------------------------------------------------------------------
void qSlicerLoadableMVoxMeshGenModuleWidget::onApplyButtonClicked()
{
  Q_D(qSlicerLoadableMVoxMeshGenModuleWidget);

  vtkSlicerLoadableMVoxMeshGenLogic* logic = 
    vtkSlicerLoadableMVoxMeshGenLogic::SafeDownCast(this->logic());
  
  if (!logic)
  {
    qCritical() << "LoadableMVoxMeshGen logic is invalid";
    return;
  }

  // Get input parameters from UI
  QString meshOutputPath = d->MeshOutputPathLineEdit->currentPath();
  QString tensorsOutputPath = d->TensorsOutputPathLineEdit->currentPath();
  vtkMRMLNode* masksNode = d->MasksInputSelector->currentNode();
  vtkMRMLNode* attributesNode = d->AttributesInputSelector->currentNode();
  vtkMRMLNode* tensorsNode = d->TensorsInputSelector->currentNode();
  bool symmetric = d->SymmetricCheckBox->isChecked();
  
  // Get advanced parameters
  int nx = d->NxSpinBox->value();
  int ny = d->NySpinBox->value();
  int nz = d->NzSpinBox->value();
  int vx = d->VxSpinBox->value();
  int vy = d->VySpinBox->value();
  int vz = d->VzSpinBox->value();

  // Validate inputs
  if (meshOutputPath.isEmpty())
  {
    qWarning() << "Mesh output path is required";
    return;
  }

  // Call logic to run MVox
  logic->RunMVox(
    meshOutputPath.toStdString(),
    tensorsOutputPath.toStdString(),
    masksNode,
    attributesNode,
    tensorsNode,
    symmetric,
    nx, ny, nz,
    vx, vy, vz
  );
}
