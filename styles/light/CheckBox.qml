// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
// Qt-Security score:significant reason:default

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import Nymea 1.0

T.CheckBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    // keep in sync with CheckDelegate.qml (shared CheckIndicator.qml was removed for performance reasons)
    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20

        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: 4
        color: control.checkState === Qt.Checked ?
                   Style.colors.components_Forms_Selection_controls_Selected :
                   Style.colors.typography_Background_Default
        border.width: control.checkState === Qt.Checked ? 0 : 2
        border.color: Style.colors.components_Forms_Selection_controls_Unselected
        opacity: control.enabled ? 1 : 0.3

        ColorImage {
            anchors.centerIn: parent
            width: 16
            height: 16
            color: Style.colors.typography_Background_Default
            source: "qrc:/icons/check.svg"
            visible: control.checkState === Qt.Checked
        }

        ColorImage {
            anchors.centerIn: parent
            width: 16
            height: 16
            color: Style.colors.components_Forms_Selection_controls_Selected
            source: "qrc:/icons/check_indeterminate_small.svg"
            visible: control.checkState === Qt.PartiallyChecked
        }
    }

    contentItem: CheckLabel {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

        text: control.text
        font: control.font
        color: control.palette.windowText
    }
}
