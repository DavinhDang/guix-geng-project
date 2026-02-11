/********************************************************************************
** Form generated from reading UI file 'qSlicerLoadableMVoxMeshGenModuleWidget.ui'
**
** Created by: Qt User Interface Compiler version 5.15.2
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QSLICERLOADABLEMVOXMESHGENMODULEWIDGET_H
#define UI_QSLICERLOADABLEMVOXMESHGENMODULEWIDGET_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QFormLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QVBoxLayout>
#include "ctkCollapsibleButton.h"
#include "ctkPathLineEdit.h"
#include "qMRMLNodeComboBox.h"
#include "qSlicerWidget.h"

QT_BEGIN_NAMESPACE

class Ui_qSlicerLoadableMVoxMeshGenModuleWidget
{
public:
    QVBoxLayout *verticalLayout;
    ctkCollapsibleButton *InputsCollapsibleButton;
    QFormLayout *formLayout;
    QLabel *MeshOutputLabel;
    ctkPathLineEdit *MeshOutputPathLineEdit;
    QLabel *TensorsOutputLabel;
    ctkPathLineEdit *TensorsOutputPathLineEdit;
    QLabel *MasksInputLabel;
    qMRMLNodeComboBox *MasksInputSelector;
    QLabel *AttributesInputLabel;
    qMRMLNodeComboBox *AttributesInputSelector;
    QLabel *TensorsInputLabel;
    qMRMLNodeComboBox *TensorsInputSelector;
    QLabel *SymmetricLabel;
    QCheckBox *SymmetricCheckBox;
    ctkCollapsibleButton *AdvancedCollapsibleButton;
    QFormLayout *formLayout_2;
    QLabel *NxLabel;
    QSpinBox *NxSpinBox;
    QLabel *NyLabel;
    QSpinBox *NySpinBox;
    QLabel *NzLabel;
    QSpinBox *NzSpinBox;
    QLabel *VxLabel;
    QSpinBox *VxSpinBox;
    QLabel *VyLabel;
    QSpinBox *VySpinBox;
    QLabel *VzLabel;
    QSpinBox *VzSpinBox;
    QPushButton *ApplyButton;
    QSpacerItem *verticalSpacer;

    void setupUi(qSlicerWidget *qSlicerLoadableMVoxMeshGenModuleWidget)
    {
        if (qSlicerLoadableMVoxMeshGenModuleWidget->objectName().isEmpty())
            qSlicerLoadableMVoxMeshGenModuleWidget->setObjectName(QString::fromUtf8("qSlicerLoadableMVoxMeshGenModuleWidget"));
        qSlicerLoadableMVoxMeshGenModuleWidget->resize(400, 600);
        verticalLayout = new QVBoxLayout(qSlicerLoadableMVoxMeshGenModuleWidget);
        verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
        InputsCollapsibleButton = new ctkCollapsibleButton(qSlicerLoadableMVoxMeshGenModuleWidget);
        InputsCollapsibleButton->setObjectName(QString::fromUtf8("InputsCollapsibleButton"));
        formLayout = new QFormLayout(InputsCollapsibleButton);
        formLayout->setObjectName(QString::fromUtf8("formLayout"));
        MeshOutputLabel = new QLabel(InputsCollapsibleButton);
        MeshOutputLabel->setObjectName(QString::fromUtf8("MeshOutputLabel"));

        formLayout->setWidget(0, QFormLayout::LabelRole, MeshOutputLabel);

        MeshOutputPathLineEdit = new ctkPathLineEdit(InputsCollapsibleButton);
        MeshOutputPathLineEdit->setObjectName(QString::fromUtf8("MeshOutputPathLineEdit"));
        MeshOutputPathLineEdit->setFilters(ctkPathLineEdit::Files);

        formLayout->setWidget(0, QFormLayout::FieldRole, MeshOutputPathLineEdit);

        TensorsOutputLabel = new QLabel(InputsCollapsibleButton);
        TensorsOutputLabel->setObjectName(QString::fromUtf8("TensorsOutputLabel"));

        formLayout->setWidget(1, QFormLayout::LabelRole, TensorsOutputLabel);

        TensorsOutputPathLineEdit = new ctkPathLineEdit(InputsCollapsibleButton);
        TensorsOutputPathLineEdit->setObjectName(QString::fromUtf8("TensorsOutputPathLineEdit"));
        TensorsOutputPathLineEdit->setFilters(ctkPathLineEdit::Files);

        formLayout->setWidget(1, QFormLayout::FieldRole, TensorsOutputPathLineEdit);

        MasksInputLabel = new QLabel(InputsCollapsibleButton);
        MasksInputLabel->setObjectName(QString::fromUtf8("MasksInputLabel"));

        formLayout->setWidget(2, QFormLayout::LabelRole, MasksInputLabel);

        MasksInputSelector = new qMRMLNodeComboBox(InputsCollapsibleButton);
        MasksInputSelector->setObjectName(QString::fromUtf8("MasksInputSelector"));
        MasksInputSelector->setAddEnabled(false);
        MasksInputSelector->setRemoveEnabled(false);

        formLayout->setWidget(2, QFormLayout::FieldRole, MasksInputSelector);

        AttributesInputLabel = new QLabel(InputsCollapsibleButton);
        AttributesInputLabel->setObjectName(QString::fromUtf8("AttributesInputLabel"));

        formLayout->setWidget(3, QFormLayout::LabelRole, AttributesInputLabel);

        AttributesInputSelector = new qMRMLNodeComboBox(InputsCollapsibleButton);
        AttributesInputSelector->setObjectName(QString::fromUtf8("AttributesInputSelector"));
        AttributesInputSelector->setAddEnabled(false);
        AttributesInputSelector->setRemoveEnabled(false);

        formLayout->setWidget(3, QFormLayout::FieldRole, AttributesInputSelector);

        TensorsInputLabel = new QLabel(InputsCollapsibleButton);
        TensorsInputLabel->setObjectName(QString::fromUtf8("TensorsInputLabel"));

        formLayout->setWidget(4, QFormLayout::LabelRole, TensorsInputLabel);

        TensorsInputSelector = new qMRMLNodeComboBox(InputsCollapsibleButton);
        TensorsInputSelector->setObjectName(QString::fromUtf8("TensorsInputSelector"));
        TensorsInputSelector->setAddEnabled(false);
        TensorsInputSelector->setRemoveEnabled(false);

        formLayout->setWidget(4, QFormLayout::FieldRole, TensorsInputSelector);

        SymmetricLabel = new QLabel(InputsCollapsibleButton);
        SymmetricLabel->setObjectName(QString::fromUtf8("SymmetricLabel"));

        formLayout->setWidget(5, QFormLayout::LabelRole, SymmetricLabel);

        SymmetricCheckBox = new QCheckBox(InputsCollapsibleButton);
        SymmetricCheckBox->setObjectName(QString::fromUtf8("SymmetricCheckBox"));

        formLayout->setWidget(5, QFormLayout::FieldRole, SymmetricCheckBox);


        verticalLayout->addWidget(InputsCollapsibleButton);

        AdvancedCollapsibleButton = new ctkCollapsibleButton(qSlicerLoadableMVoxMeshGenModuleWidget);
        AdvancedCollapsibleButton->setObjectName(QString::fromUtf8("AdvancedCollapsibleButton"));
        AdvancedCollapsibleButton->setCollapsed(true);
        formLayout_2 = new QFormLayout(AdvancedCollapsibleButton);
        formLayout_2->setObjectName(QString::fromUtf8("formLayout_2"));
        NxLabel = new QLabel(AdvancedCollapsibleButton);
        NxLabel->setObjectName(QString::fromUtf8("NxLabel"));

        formLayout_2->setWidget(0, QFormLayout::LabelRole, NxLabel);

        NxSpinBox = new QSpinBox(AdvancedCollapsibleButton);
        NxSpinBox->setObjectName(QString::fromUtf8("NxSpinBox"));
        NxSpinBox->setMaximum(10000);

        formLayout_2->setWidget(0, QFormLayout::FieldRole, NxSpinBox);

        NyLabel = new QLabel(AdvancedCollapsibleButton);
        NyLabel->setObjectName(QString::fromUtf8("NyLabel"));

        formLayout_2->setWidget(1, QFormLayout::LabelRole, NyLabel);

        NySpinBox = new QSpinBox(AdvancedCollapsibleButton);
        NySpinBox->setObjectName(QString::fromUtf8("NySpinBox"));
        NySpinBox->setMaximum(10000);

        formLayout_2->setWidget(1, QFormLayout::FieldRole, NySpinBox);

        NzLabel = new QLabel(AdvancedCollapsibleButton);
        NzLabel->setObjectName(QString::fromUtf8("NzLabel"));

        formLayout_2->setWidget(2, QFormLayout::LabelRole, NzLabel);

        NzSpinBox = new QSpinBox(AdvancedCollapsibleButton);
        NzSpinBox->setObjectName(QString::fromUtf8("NzSpinBox"));
        NzSpinBox->setMaximum(10000);

        formLayout_2->setWidget(2, QFormLayout::FieldRole, NzSpinBox);

        VxLabel = new QLabel(AdvancedCollapsibleButton);
        VxLabel->setObjectName(QString::fromUtf8("VxLabel"));

        formLayout_2->setWidget(3, QFormLayout::LabelRole, VxLabel);

        VxSpinBox = new QSpinBox(AdvancedCollapsibleButton);
        VxSpinBox->setObjectName(QString::fromUtf8("VxSpinBox"));
        VxSpinBox->setMaximum(10000);

        formLayout_2->setWidget(3, QFormLayout::FieldRole, VxSpinBox);

        VyLabel = new QLabel(AdvancedCollapsibleButton);
        VyLabel->setObjectName(QString::fromUtf8("VyLabel"));

        formLayout_2->setWidget(4, QFormLayout::LabelRole, VyLabel);

        VySpinBox = new QSpinBox(AdvancedCollapsibleButton);
        VySpinBox->setObjectName(QString::fromUtf8("VySpinBox"));
        VySpinBox->setMaximum(10000);

        formLayout_2->setWidget(4, QFormLayout::FieldRole, VySpinBox);

        VzLabel = new QLabel(AdvancedCollapsibleButton);
        VzLabel->setObjectName(QString::fromUtf8("VzLabel"));

        formLayout_2->setWidget(5, QFormLayout::LabelRole, VzLabel);

        VzSpinBox = new QSpinBox(AdvancedCollapsibleButton);
        VzSpinBox->setObjectName(QString::fromUtf8("VzSpinBox"));
        VzSpinBox->setMaximum(10000);

        formLayout_2->setWidget(5, QFormLayout::FieldRole, VzSpinBox);


        verticalLayout->addWidget(AdvancedCollapsibleButton);

        ApplyButton = new QPushButton(qSlicerLoadableMVoxMeshGenModuleWidget);
        ApplyButton->setObjectName(QString::fromUtf8("ApplyButton"));

        verticalLayout->addWidget(ApplyButton);

        verticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout->addItem(verticalSpacer);


        retranslateUi(qSlicerLoadableMVoxMeshGenModuleWidget);

        QMetaObject::connectSlotsByName(qSlicerLoadableMVoxMeshGenModuleWidget);
    } // setupUi

    void retranslateUi(qSlicerWidget *qSlicerLoadableMVoxMeshGenModuleWidget)
    {
        InputsCollapsibleButton->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Files", nullptr));
        MeshOutputLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Mesh output file:", nullptr));
        MeshOutputPathLineEdit->setProperty("settingKey", QVariant(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "LoadableMVoxMeshGen/MeshOutputPath", nullptr)));
        TensorsOutputLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Tensors output file:", nullptr));
        TensorsOutputPathLineEdit->setProperty("settingKey", QVariant(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "LoadableMVoxMeshGen/TensorsOutputPath", nullptr)));
        MasksInputLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Mask input file:", nullptr));
        MasksInputSelector->setNodeTypes(QStringList()
            << QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vtkMRMLLabelMapVolumeNode", nullptr));
        AttributesInputLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Attribute input image:", nullptr));
        AttributesInputSelector->setNodeTypes(QStringList()
            << QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vtkMRMLLabelMapVolumeNode", nullptr));
        TensorsInputLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Tensor input image:", nullptr));
        TensorsInputSelector->setNodeTypes(QStringList()
            << QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vtkMRMLDiffusionTensorVolumeNode", nullptr));
        SymmetricLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Symmetric tensor output:", nullptr));
        AdvancedCollapsibleButton->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Image parameters", nullptr));
        NxLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "nx:", nullptr));
        NyLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "ny:", nullptr));
        NzLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "nz:", nullptr));
        VxLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vx:", nullptr));
        VyLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vy:", nullptr));
        VzLabel->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "vz:", nullptr));
        ApplyButton->setText(QCoreApplication::translate("qSlicerLoadableMVoxMeshGenModuleWidget", "Apply", nullptr));
        (void)qSlicerLoadableMVoxMeshGenModuleWidget;
    } // retranslateUi

};

namespace Ui {
    class qSlicerLoadableMVoxMeshGenModuleWidget: public Ui_qSlicerLoadableMVoxMeshGenModuleWidget {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QSLICERLOADABLEMVOXMESHGENMODULEWIDGET_H
