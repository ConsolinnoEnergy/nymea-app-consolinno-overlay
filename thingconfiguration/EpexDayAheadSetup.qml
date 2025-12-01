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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    property ThingClass thingClass: thing ? thing.thingClass : null

    // Optional: If set, it will be reconfigred, otherwise a new one will be created
    property Thing thing: null

    signal aborted();
    signal done();

    QtObject {
        id: d
        property ThingDescriptor thingDescriptor: null
        property var discoveryParams: []
        property string thingName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property string name: ""
        property var params: []

        function pairThing() {
            if (root.thingClass.setupMethod !== 0) {
                console.warn("Unexpected setup method for ", root.thingClass.displayName);
                return;
            }

            if (root.thing) {
                engine.thingManager.reconfigureThing(root.thing.id, params);
            } else {
                engine.thingManager.addThing(root.thingClass.id, d.name, params);
            }

            busyOverlay.shown = true;
        }
    }

    Component.onCompleted: {
        console.debug("Starting setup wizard. Create Methods:",
                      root.thingClass.createMethods,
                      "Setup method:",
                      root.thingClass.setupMethod);

        if (root.thingClass.createMethods.indexOf("CreateMethodUser") === -1) {
            console.warn("Expected create method \"user\" not found");
            return;
        }

        if (!root.thing) {
            // Setting up a new thing
            console.debug("Setting up new thing");
            internalPageStack.push(paramsPage);
        } else if (root.thing) {
            // Reconfigure
            console.debug("Reconfiguring existing thing")
            if (root.thingClass.paramTypes.count > 0) {
                // There are params. Open params page in any case
                console.debug("Params:", root.thingClass.paramTypes.count)
                internalPageStack.push(paramsPage)
            } else {
                // No params... go straight to reconfigure/repair
                console.debug("No params")
                if (root.thingClass.setupMethod !== 0) {
                    console.warn("Unexpected setup method for ", root.thingClass.displayName);
                    return;
                }
                print("reconfiguring...")
                // This totally does not make sense... Maybe we should hide the reconfigure button if there are no params?
                engine.thingManager.reconfigureThing(root.thing.id, [])
                busyOverlay.shown = true;
            }
        }
    }

    Connections {
        target: engine.thingManager
        onAddThingReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage})
        }
        onReconfigureThingReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: root.thing.id, message: displayMessage})
        }
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }
    property QtObject pageStack: QtObject {
        function pop(item) {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop(item)
            } else {
                root.aborted()
            }
        }
    }

    Component {
        id: paramsPage

        SettingsPageBase {
            id: paramsView
            title: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)

            SettingsPageSectionHeader {
                text: qsTr("Name the thing:")
                visible: root.thing ? false : true
            }

            TextField {
                id: nameTextField
                visible: root.thing ? false : true
                text: (d.thingName ? d.thingName : root.thingClass.displayName)
                      + (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/) ? " (" + PlatformHelper.machineHostname + ")" : "")
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
            }

            SettingsPageSectionHeader {
                text: qsTr("Thing parameters")
                visible: paramRepeater.count > 0
            }

            Component.onCompleted: {
                if (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/)) {
                    console.warn("checking Notification permission!")
                    if (PlatformPermissions.notificationsPermission != PlatformPermissions.PermissionStatusGranted) {
                        console.warn("Notification permission missing!")
                        PlatformPermissions.requestPermission(PlatformPermissions.PermissionNotifications)
                    }
                }
            }

            Repeater {
                id: paramRepeater
                model: engine.jsonRpcClient.ensureServerVersion("1.12") || d.thingDescriptor == null ?  root.thingClass.paramTypes : null
                delegate: ParamDelegate {
                    //                            Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    enabled: !model.readOnly
                    paramType: root.thingClass.paramTypes.get(index)
                    value: {
                        // Discovery, use params from discovered descriptor
                        if (d.thingDescriptor && d.thingDescriptor.params.getParam(paramType.id)) {
                            return d.thingDescriptor.params.getParam(paramType.id).value
                        }

                        // Special hook for push notifications as we need to provide the token etc implicitly
                        print("Setting up params for thing class:", root.thingClass.id, root.thingClass.name)
                        if (root.thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/)) {
                            if (paramType.id.toString().match(/\{?3cb8e30e-2ec5-4b4b-8c8c-03eaf7876839\}?/)) {
                                return PushNotifications.service;
                            }
                            if (paramType.id.toString().match(/\{?12ec06b2-44e7-486a-9169-31c684b91c8f\}?/)) {
                                return PushNotifications.token;
                            }
                            if (paramType.id.toString().match(/\{?d76da367-64e3-4b7d-aa84-c96b3acfb65e\}?/)) {
                                return PushNotifications.clientId + "+" + Configuration.appId;
                            }
                        }

                        // Show current param value when reconfiguring a thing and default value
                        // when setting up a new thing.
                        if (root.thing) {
                            var param = root.thing.params.getParam(paramType.id);
                            return param.value
                        } else {
                            return root.thingClass.paramTypes.get(index).defaultValue
                        }
                    }
                }
            }

            SecondaryButton {
                visible: root.thing ? true : false
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: Style.bigMargins

                text: qsTr("Reset values to default")
                onClicked: {
                    // Need to force reload of model here since otherwise the code below
                    // (to set the parameters to their default values) does not work once
                    // the user made changes to the parameters.
                    var model = paramRepeater.model
                    paramRepeater.model = []
                    paramRepeater.model = model
                    for (var i = 0; i < paramRepeater.count; i++) {
                        paramRepeater.itemAt(i).value = paramRepeater.itemAt(i).paramType.defaultValue
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins

                text: "OK"
                onClicked: {
                    var params = []
                    for (var i = 0; i < paramRepeater.count; i++) {
                        var param = {}
                        var paramType = paramRepeater.itemAt(i).paramType
                        if (!paramType.readOnly) {
                            param.paramTypeId = paramType.id
                            param.value = paramRepeater.itemAt(i).value
                            print("adding param", param.paramTypeId, param.value)
                            params.push(param)
                        }
                    }

                    d.params = params
                    d.name = nameTextField.text
                    d.pairThing();
                }
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            header: NymeaHeader {
                text: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)
                onBackPressed: pageStack.pop()
            }

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError

            readonly property Thing thing: root.thing ? root.thing : engine.thingManager.things.getThing(thingId)

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.thing ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing.name) : qsTr("Something went wrong setting up this thing...");
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: "Retry"
                    onClicked: {
                        internalPageStack.pop({immediate: true});
                        internalPageStack.pop({immediate: true});
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done();
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
