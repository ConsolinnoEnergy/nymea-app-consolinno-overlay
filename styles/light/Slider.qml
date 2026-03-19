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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.impl 2.12
import QtQuick.Templates 2.12 as T
import Nymea 1.0

T.Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)

    padding: 6

    // #TODO disabled state

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: 30
        implicitHeight: 30
        radius: width / 2
        color: control.pressed ?
                   Style.colors.components_Forms_Slider_Handle_pressed_accent :
                     control.hovered ?
                         Style.colors.components_Forms_Slider_Handle_hover_accent :
                         "transparent"

        Rectangle {
            property int ringWidth: control.pressed ? 5 : 7
            anchors.centerIn: parent
            width: parent.width - 2 * ringWidth
            height: parent.height - 2 * ringWidth
            radius: width / 2
            color: Style.colors.components_Forms_Slider_Handle
        }
    }

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 200 : 6
        implicitHeight: control.horizontal ? 6 : 200
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight
        radius: 4
        color: Style.colors.components_Forms_Slider_Track
        scale: control.horizontal && control.mirrored ? -1 : 1
        opacity: Style.numbers.components_Disabled_opacity

    }

    // This is usually a child of the background Rectangle. But since the background color is specified using opacity
    // in our design, we need to pull this Rectangle out of the background Rectangle due to opacity inheritance.
    Rectangle {
        property int backgroundX: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - backgroundWidth) / 2)
        property int backgroundY: control.topPadding + (control.horizontal ? (control.availableHeight - backgroundHeight) / 2 : 0)
        property int backgroundImplicitWidth: control.horizontal ? 200 : 6
        property int backgroundImplicitHeight: control.horizontal ? 6 : 200
        property int backgroundWidth: control.horizontal ? control.availableWidth : backgroundImplicitWidth
        property int backgroundHeight: control.horizontal ? backgroundImplicitHeight : control.availableHeight
        x: backgroundX
        y: backgroundY + (control.horizontal ? 0 : control.visualPosition * backgroundHeight)
        width: control.horizontal ? control.position * backgroundWidth : 6
        height: control.horizontal ? 6 : control.position * backgroundHeight
        radius: 4
        color: Style.colors.components_Forms_Slider_Track
    }
}
