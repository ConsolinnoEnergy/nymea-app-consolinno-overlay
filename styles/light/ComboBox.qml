/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T
import QtGraphicalEffects 1.15
import Nymea 1.0

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 4 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 4 : indicator.width + spacing)

    font: Style.newParagraphFont

    delegate: ItemDelegate {
        width: ListView.view.width
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        font: Style.newParagraphFont
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        leftPadding: 12
        palette.text: Style.colors.components_Forms_Fields_Field_user_input
        palette.highlightedText: palette.text
        palette.highlight: Style.colors.typography_Background_Selection
        palette.midlight: palette.highlight
        palette.light: Style.colors.typography_Background_Default
    }

    indicator: ColorImage {
        x: control.mirrored ? control.padding + 16 : control.width - width - control.padding - 16
        y: control.topPadding + (control.availableHeight - height) / 2
        color: Style.colors.brand_Basic_Icon
        width: 13
        height: 8
        defaultColor: "#353637"
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/drop-indicator.png"
        opacity: enabled ? 1 : 0.3
    }

    contentItem: T.TextField {
        leftPadding: !control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        topPadding: 6 - control.padding
        bottomPadding: 6 - control.padding

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse

        font: control.font
        color: control.editable ? control.palette.text : control.palette.buttonText
        selectionColor: control.palette.highlight
        selectedTextColor: control.palette.highlightedText
        verticalAlignment: Text.AlignVCenter

        background: Rectangle {
            visible: control.enabled && control.editable && !control.flat
            border.width: parent && parent.activeFocus ? 2 : 1
            border.color: parent && parent.activeFocus ? control.palette.highlight : control.palette.button
            color: control.palette.base
        }
    }

    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 56

        color: control.pressed ?
                   Style.colors.typography_States_Hover_pressed_outline :
                   control.hovered ?
                       Style.colors.typography_States_Hover :
                       "transparent"
        border.width: 0
        radius: Style.cornerRadius + 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4

            radius: Style.cornerRadius
            border.width: 1
            color: control.down ?
                       "transparent" :
                       Style.colors.typography_Background_Default
            border.color: control.enabled ?
                              Style.colors.components_Forms_Fields_Field_border :
                              Style.colors.components_Forms_Slider_Thumb_Track_disabled
        }
    }

    popup: T.Popup {
        x: 4
        y: 4
        width: control.width - 8
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        topMargin: 6
        bottomMargin: 6

        Item {
            id: roundedRectMask
            width: parent.width
            height: parent.height
            layer.enabled: true
            visible: false
            Rectangle {
                anchors.fill: parent
                radius: Style.cornerRadius
            }
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            T.ScrollIndicator.vertical: ScrollIndicator { }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: roundedRectMask
            }
        }

        background: Rectangle {
            color: Style.colors.typography_Background_Default
            radius: Style.cornerRadius
            border.width: 1
            border.color: Style.colors.components_Forms_Fields_Field_border
        }
    }
}
