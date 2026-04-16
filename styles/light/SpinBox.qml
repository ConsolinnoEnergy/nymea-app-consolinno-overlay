// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
// Qt-Security score:significant reason:default

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Nymea 1.0

T.SpinBox {
    id: control

    // Note: the width of the indicators are calculated into the padding
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))

    font: Style.newParagraphFont

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    readonly property alias acceptableInput: spinBoxInput.acceptableInput

    contentItem: TextInput {
        id: spinBoxInput
        z: 2
        text: control.displayText
        clip: width < implicitWidth
        padding: 6

        font: control.font
        color: Style.colors.components_Forms_Fields_Field_user_input
        selectionColor: control.palette.highlight
        selectedTextColor: control.palette.highlightedText
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
    }

    up.indicator: Rectangle {
        x: parent.width - width - bg.anchors.margins - bg.border.width
        y: bg.anchors.margins + bg.border.width
        height: control.height - bg.anchors.margins * 2 - bg.border.width * 2
        implicitWidth: 27
        implicitHeight: 37
        radius: Style.cornerRadius
        color: control.up.pressed ?
                   Style.colors.typography_States_Pressed :
                   control.up.hovered ?
                       Style.colors.typography_States_Hover :
                       "transparent"

        ColorImage {
            anchors.centerIn: parent
            color: Style.colors.brand_Basic_Icon
            width: 20
            height: 20
            source: "qrc:/icons/add.svg"
        }
    }

    down.indicator: Rectangle {
        x: bg.anchors.margins + bg.border.width
        y: bg.anchors.margins + bg.border.width
        height: control.height - bg.anchors.margins * 2 - bg.border.width * 2
        implicitWidth: 27
        implicitHeight: 37
        radius: Style.cornerRadius
        color: control.down.pressed ?
                   Style.colors.typography_States_Pressed :
                   control.down.hovered ?
                       Style.colors.typography_States_Hover :
                       "transparent"

        ColorImage {
            anchors.centerIn: parent
            color: Style.colors.brand_Basic_Icon
            width: 20
            height: 20
            source: "qrc:/icons/check_indeterminate_small.svg"
        }
    }

    background: Rectangle {
        implicitWidth: 140

        radius: Style.cornerRadius + 2
        color: (control.hovered &&
                !control.activeFocus &&
                !control.up.pressed &&
                !control.up.hovered &&
                !control.down.pressed &&
                !control.down.hovered) ?
                   Style.colors.typography_States_Hover_pressed_outline :
                   "transparent"

        Rectangle {
            id: bg
            anchors.fill: parent
            anchors.margins: 4
            radius: Style.cornerRadius
            border.width: control.activeFocus ? 2 : 1
            color: control.acceptableInput ?
                       Style.colors.typography_Background_Default :
                       Style.colors.system_Danger_Background
            border.color: !control.enabled ?
                              Style.colors.components_Forms_Slider_Thumb_Track_disabled :
                              !control.acceptableInput ?
                                  Style.colors.system_Danger_Accent :
                                  control.activeFocus ?
                                      Style.colors.components_Forms_Fields_Field_border_active :
                                      Style.colors.components_Forms_Fields_Field_border
        }
    }
}
