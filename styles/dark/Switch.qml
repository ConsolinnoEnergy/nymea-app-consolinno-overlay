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

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Controls.impl
import Qt5Compat.GraphicalEffects
import Nymea 1.0

T.Switch {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    indicator: Rectangle {
        implicitWidth: 42
        implicitHeight: 20

        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: height / 2
        color: {
            if (control.checked) {
                return control.enabled ?
                            Style.colors.components_Forms_Toggle_Track_active :
                            Style.colors.components_Forms_Toggle_Toggle_disabled;
            } else {
                if (control.pressed) {
                    return Style.colors.typography_States_Pressed;
                } else if (control.hovered) {
                    return Style.colors.typography_States_Hover;
                } else {
                    return "transparent";
                }
            }
        }

        border.width: control.checked ? 0 : 1
        border.color: control.enabled ?
                          Style.colors.components_Forms_Toggle_Thumb_Track_inactive :
                          Style.colors.components_Forms_Toggle_Toggle_disabled

        Rectangle {
            x: Math.max(4, Math.min(parent.width - width - 4, control.visualPosition * parent.width - (width / 2) + 4))
            y: (parent.height - height) / 2
            width: 12
            height: 12
            radius: width / 2
            color: control.checked ?
                       Style.colors.components_Forms_Toggle_Thumb_active :
                       control.enabled ?
                           Style.colors.components_Forms_Toggle_Thumb_Track_inactive :
                           Style.colors.components_Forms_Toggle_Toggle_disabled

            Behavior on x {
                enabled: !control.down
                SmoothedAnimation { velocity: 100 }
            }
        }

    }

    contentItem: CheckLabel {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

        text: control.text
        font: control.font
        color: control.palette.windowText
        visible: false
    }
}
