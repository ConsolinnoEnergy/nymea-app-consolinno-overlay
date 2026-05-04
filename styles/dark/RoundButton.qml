// Copyright (C) 2017 The Qt Company Ltd.
// Copyright (C) 2026 Consolinno Energy GmbH
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
// Qt-Security score:significant reason:default

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import Nymea 1.0

T.RoundButton {
    id: control

    property bool secondary: false

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 8
    spacing: 6

    topInset: 4
    bottomInset: 4
    leftInset: 4
    rightInset: 4

    opacity: !control.enabled ? Style.numbers.components_Disabled_opacity : 1
    font: Style.newParagraphFontBold

    icon.width: 24
    icon.height: 24
    icon.color: control.checked || control.highlighted ? control.palette.brightText :
                control.flat && !control.down ? (control.visualFocus ? control.palette.highlight : control.palette.windowText) : control.palette.buttonText

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: Style.colors.brand_Basic_Icon
    }

    background: Rectangle {
        implicitWidth: control.icon.width + 2 * control.padding
        implicitHeight: control.icon.height + 2 * control.padding

        width: parent.width - control.leftInset - control.rightInset
        height: parent.height - control.topInset - control.bottomInset
        radius: height / 2
        color: {
            if (control.secondary) {
                if (control.pressed) {
                    return Style.colors.typography_States_Pressed;
                } else if (control.hovered) {
                    return Style.colors.typography_Background_Default;
                } else {
                    return "transparent";
                }
            } else {
                return Style.colors.components_Forms_Buttons_Button_primary;
            }
        }
        border.width: control.secondary ? 0 : 1
        border.color: Style.colors.components_Forms_Buttons_Button_primary_border

        Rectangle {
            width: parent.width
            height: parent.height
            radius: height / 2
            color: Style.colors.typography_States_Pressed
            visible: control.pressed && !control.secondary
        }

        Rectangle {
            x: -4
            y: -4
            width: parent.width + 8
            height: parent.height + 8
            radius: height / 2
            visible: control.enabled && control.hovered
            color: "transparent"
            border.width: 4
            border.color: Style.colors.typography_States_Hover_pressed_outline
        }
    }
}
