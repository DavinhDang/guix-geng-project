#ifndef __qSlicerLoadableMVoxMeshGenModuleWidget_h
#define __qSlicerLoadableMVoxMeshGenModuleWidget_h

// Slicer includes
#include "qSlicerAbstractModuleWidget.h"

#include "qSlicerLoadableMVoxMeshGenModuleExport.h"

class qSlicerLoadableMVoxMeshGenModuleWidgetPrivate;
class vtkMRMLNode;

class Q_SLICER_QTMODULES_LoadableMVoxMeshGen_EXPORT qSlicerLoadableMVoxMeshGenModuleWidget :
  public qSlicerAbstractModuleWidget
{
  Q_OBJECT

public:

  typedef qSlicerAbstractModuleWidget Superclass;
  qSlicerLoadableMVoxMeshGenModuleWidget(QWidget *parent=0);
  virtual ~qSlicerLoadableMVoxMeshGenModuleWidget();

public slots:

protected:
  QScopedPointer<qSlicerLoadableMVoxMeshGenModuleWidgetPrivate> d_ptr;

  virtual void setup();

protected slots:
  void onApplyButtonClicked();

private:
  Q_DECLARE_PRIVATE(qSlicerLoadableMVoxMeshGenModuleWidget);
  Q_DISABLE_COPY(qSlicerLoadableMVoxMeshGenModuleWidget);
};

#endif
