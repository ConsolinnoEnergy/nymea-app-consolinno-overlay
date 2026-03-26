/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.5 as T
import QtQuick.Controls 2.5
import QtQuick.Controls.impl 2.5
import Nymea 1.0

import "../../ui/components"

T.Button {
    id: control

    property bool secondary: false
    property alias iconLeft: iconLeft.name
    property alias iconRight: iconRight.name

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    topPadding: Style.numbers.components_Forms_Buttons_Vertical_padding
    bottomPadding: Style.numbers.components_Forms_Buttons_Vertical_padding
    leftPadding: Style.numbers.components_Forms_Buttons_Horizontal_padding
    rightPadding: Style.numbers.components_Forms_Buttons_Horizontal_padding
    topInset: 4
    bottomInset: 4
    leftInset: 4
    rightInset: 4
    opacity: !control.enabled ? Style.numbers.components_Disabled_opacity : 1

    contentItem: RowLayout {
        spacing: Style.smallMargins

        ColorIcon {
            id: iconLeft
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            size: 20
            color: Style.colors.brand_Basic_Icon
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: control.text
            color: control.secondary ?
                       Style.colors.typography_Basic_Default :
                       Style.colors.components_Forms_Buttons_Button_primary_text
            font: Style.newParagraphFont

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        ColorIcon {
            id: iconRight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            size: 20
            color: Style.colors.brand_Basic_Icon
        }
    }

//    contentItem: Text {
//        text: control.text
//        color: control.secondary ?
//                   Style.colors.typography_Basic_Default :
//                   Style.colors.components_Forms_Buttons_Button_primary_text
//        font: Style.newParagraphFont

//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        elide: Text.ElideRight
//    }

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 48

        width: parent.width
        height: parent.height // - 12
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
            visible: control.hovered
            color: "transparent"
            border.width: 4
            border.color: Style.colors.typography_States_Hover_pressed_outline
        }
    }
}
