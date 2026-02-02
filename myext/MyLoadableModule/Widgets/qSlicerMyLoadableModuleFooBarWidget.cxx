/*==============================================================================

  Program: 3D Slicer

  Copyright (c) Kitware Inc.

  See COPYRIGHT.txt
  or http://www.slicer.org/copyright/copyright.txt for details.

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  This file was originally developed by Jean-Christophe Fillion-Robin, Kitware Inc.
  and was partially funded by NIH grant 3P41RR013218-12S1

==============================================================================*/

// FooBar Widgets includes
#include "qSlicerMyLoadableModuleFooBarWidget.h"
#include "ui_qSlicerMyLoadableModuleFooBarWidget.h"

//-----------------------------------------------------------------------------
class qSlicerMyLoadableModuleFooBarWidgetPrivate
  : public Ui_qSlicerMyLoadableModuleFooBarWidget
{
  Q_DECLARE_PUBLIC(qSlicerMyLoadableModuleFooBarWidget);
protected:
  qSlicerMyLoadableModuleFooBarWidget* const q_ptr;

public:
  qSlicerMyLoadableModuleFooBarWidgetPrivate(
    qSlicerMyLoadableModuleFooBarWidget& object);
  virtual void setupUi(qSlicerMyLoadableModuleFooBarWidget*);
};

// --------------------------------------------------------------------------
qSlicerMyLoadableModuleFooBarWidgetPrivate
::qSlicerMyLoadableModuleFooBarWidgetPrivate(
  qSlicerMyLoadableModuleFooBarWidget& object)
  : q_ptr(&object)
{
}

// --------------------------------------------------------------------------
void qSlicerMyLoadableModuleFooBarWidgetPrivate
::setupUi(qSlicerMyLoadableModuleFooBarWidget* widget)
{
  this->Ui_qSlicerMyLoadableModuleFooBarWidget::setupUi(widget);
}

//-----------------------------------------------------------------------------
// qSlicerMyLoadableModuleFooBarWidget methods

//-----------------------------------------------------------------------------
qSlicerMyLoadableModuleFooBarWidget
::qSlicerMyLoadableModuleFooBarWidget(QWidget* parentWidget)
  : Superclass( parentWidget )
  , d_ptr( new qSlicerMyLoadableModuleFooBarWidgetPrivate(*this) )
{
  Q_D(qSlicerMyLoadableModuleFooBarWidget);
  d->setupUi(this);
}

//-----------------------------------------------------------------------------
qSlicerMyLoadableModuleFooBarWidget
::~qSlicerMyLoadableModuleFooBarWidget()
{
}
