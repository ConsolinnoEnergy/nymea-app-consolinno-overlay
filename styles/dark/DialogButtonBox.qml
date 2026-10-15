// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
// Qt-Security score:significant reason:default

import QtQuick
import QtQuick.Templates as T
import Nymea

T.DialogButtonBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            (control.count === 1 ? implicitContentWidth * 2 : implicitContentWidth) + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentItem.childrenRect.height + topPadding + bottomPadding)
    contentWidth: contentItem.implicitWidth

    spacing: Style.smallMargins
    padding: 12
    topPadding: 0
    alignment: count === 1 ? Qt.AlignRight : undefined

    // Accept before Reject, independent of the platform default (Gnome/Mac/KDE put Reject first)
    buttonLayout: T.DialogButtonBox.WinLayout

    delegate: Button {}

    // The first button is the primary one (WinLayout puts Accept/Yes first). Every button gets an
    // explicit size, otherwise the template assigns an equal share of the box width and
    // the content height to it.
    contentItem: Column {
        spacing: control.spacing
        width: control.availableWidth
        Repeater {
            model: control.contentModel
            onItemAdded: (index, item) => {
                item.flat = Qt.binding(() => item !== control.contentModel.get(0))
                item.width = Qt.binding(() => item.flat
                                        ? Math.min(item.implicitWidth, control.availableWidth)
                                        : control.availableWidth)
                item.height = Qt.binding(() => item.implicitHeight)
                item.x = Qt.binding(() => (control.availableWidth - item.width) / 2)
            }
        }
    }

    background: null
}
