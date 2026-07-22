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
                             contentItem.implicitHeight + topPadding + bottomPadding)
    contentWidth: contentItem.implicitWidth

    spacing: Style.smallMargins
    padding: 12
    topPadding: 0
    alignment: count === 1 ? Qt.AlignRight : undefined

    delegate: Button {
        width: flat ? undefined : control.availableWidth
    }

    contentItem: Column {
        spacing: control.spacing
        width: control.availableWidth
        Repeater {
            model: control.contentModel
            onItemAdded: (index, item) => {
                item.flat = index !== 0
                if (index !== 0) {
                    item.x = Qt.binding(() => (control.availableWidth - item.width) / 2);
                }
            }
        }
    }

    background: null
}
