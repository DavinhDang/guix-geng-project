#ifndef __qSlicerLoadableMVoxMeshGenModule_h
#define __qSlicerLoadableMVoxMeshGenModule_h

// Slicer includes
#include "qSlicerLoadableModule.h"

#include "qSlicerLoadableMVoxMeshGenModuleExport.h"

class qSlicerLoadableMVoxMeshGenModulePrivate;

class Q_SLICER_QTMODULES_LoadableMVoxMeshGen_EXPORT qSlicerLoadableMVoxMeshGenModule
  : public qSlicerLoadableModule
{
  Q_OBJECT
  Q_PLUGIN_METADATA(IID "org.slicer.modules.loadable.qSlicerLoadableModule/1.0");
  Q_INTERFACES(qSlicerLoadableModule);

public:

  typedef qSlicerLoadableModule Superclass;
  explicit qSlicerLoadableMVoxMeshGenModule(QObject *parent=0);
  virtual ~qSlicerLoadableMVoxMeshGenModule();

  qSlicerGetTitleMacro(QTMODULE_TITLE);

  virtual QString helpText()const;
  virtual QString acknowledgementText()const;
  virtual QStringList contributors()const;

  virtual QIcon icon()const;

  virtual QStringList categories()const;
  virtual QStringList dependencies()const;

protected:

  /// Initialize the module. Register the volumes reader/writer
  virtual void setup();

  /// Create and return the widget representation associated to this module
  virtual qSlicerAbstractModuleRepresentation * createWidgetRepresentation();

  /// Create and return the logic associated to this module
  virtual vtkMRMLAbstractLogic* createLogic();

protected:
  QScopedPointer<qSlicerLoadableMVoxMeshGenModulePrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(qSlicerLoadableMVoxMeshGenModule);
  Q_DISABLE_COPY(qSlicerLoadableMVoxMeshGenModule);

};

#endif
