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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property Thing thing: null
    readonly property ThingClass thingClass: thing ? thing.thingClass : null

    header: NymeaHeader {
        text: root.thingClass.displayName
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Style.margins
        spacing: Style.margins

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: contentHeight
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: layout
                anchors.fill: parent
                spacing: Style.margins

                CoFrostyCard {
                    id: typeGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Type")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: root.thingClass.displayName
                            labelText: qsTr("Name")
                            interactive: false
                        }

                        CoCard {
                            Layout.fillWidth: true
                            property string typeId: root.thingClass.id.toString().replace(/[{}]/g, "")
                            text: typeId
                            labelText: qsTr("ID")
                            iconRight: "/icons/edit-copy.svg"
                            iconRightColor: Style.colors.brand_Basic_Accent
                            onClicked: {
                                PlatformHelper.toClipBoard(typeId);
                                ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: interfacesGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Interfaces")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: root.thingClass.interfaces.join(", ") + (root.thingClass.providedInterfaces.length > 0 ? " (" + root.thingClass.providedInterfaces.join(", ") + ")" : "")
                            interactive: false
                        }
                    }
                }

                CoFrostyCard {
                    id: parametersGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Parameters")
                    visible: root.thingClass.paramTypes.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.thingClass.paramTypes
                            delegate: CoCard {
                                Layout.fillWidth: true
                                property string paramId: root.thingClass.paramTypes.get(index).id.toString().replace(/[{}]/g, "")
                                text: root.thingClass.paramTypes.get(index).displayName
                                labelText: paramId
                                iconRight: "/icons/edit-copy.svg"
                                iconRightColor: Style.colors.brand_Basic_Accent
                                onClicked: {
                                    PlatformHelper.toClipBoard(paramId);
                                    ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: settingsGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Settings")
                    visible: root.thingClass.settingsTypes.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.thingClass.settingsTypes
                            delegate: CoCard {
                                Layout.fillWidth: true
                                property string settingId: root.thingClass.settingsTypes.get(index).id.toString().replace(/[{}]/g, "")
                                text: root.thingClass.settingsTypes.get(index).displayName
                                labelText: settingId
                                iconRight: "/icons/edit-copy.svg"
                                iconRightColor: Style.colors.brand_Basic_Accent
                                onClicked: {
                                    PlatformHelper.toClipBoard(settingId);
                                    ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: eventsGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Events")
                    visible: root.thingClass.eventTypes.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.thingClass.eventTypes
                            delegate: CoCard {
                                Layout.fillWidth: true
                                property string eventId: root.thingClass.eventTypes.get(index).id.toString().replace(/[{}]/g, "")
                                text: root.thingClass.eventTypes.get(index).displayName
                                labelText: eventId
                                iconRight: "/icons/edit-copy.svg"
                                iconRightColor: Style.colors.brand_Basic_Accent
                                onClicked: {
                                    PlatformHelper.toClipBoard(eventId);
                                    ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: statesGroup
                    Layout.fillWidth: true
                    headerText: qsTr("States")
                    visible: root.thingClass.stateTypes.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.thingClass.stateTypes
                            delegate: CoCard {
                                Layout.fillWidth: true
                                property string stateId: root.thingClass.stateTypes.get(index).id.toString().replace(/[{}]/g, "")
                                text: root.thingClass.stateTypes.get(index).displayName
                                labelText: stateId
                                iconRight: "/icons/edit-copy.svg"
                                iconRightColor: Style.colors.brand_Basic_Accent
                                onClicked: {
                                    PlatformHelper.toClipBoard(stateId);
                                    ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: actionsGroup
                    Layout.fillWidth: true
                    headerText: qsTr("Actions")
                    visible: root.thingClass.actionTypes.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.thingClass.actionTypes
                            delegate: CoCard {
                                Layout.fillWidth: true
                                property string actionId: root.thingClass.actionTypes.get(index).id.toString().replace(/[{}]/g, "")
                                text: root.thingClass.actionTypes.get(index).displayName
                                labelText: actionId
                                iconRight: "/icons/edit-copy.svg"
                                iconRightColor: Style.colors.brand_Basic_Accent
                                onClicked: {
                                    PlatformHelper.toClipBoard(actionId);
                                    ToolTip.show(qsTr("ID copied to clipboard"), 1000);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
