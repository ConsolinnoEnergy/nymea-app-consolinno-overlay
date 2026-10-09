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
import Nymea
import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("Connection settings")

    QtObject {
        id: d
        property int pendingCallId: -1

        // New endpoints (Hems.Get/SetRemoteConnectionEnabled) are preferred. If the
        // core system runs an older energy plugin without these endpoints, fall back
        // to the legacy variant (the app edits the tunnel proxy configuration
        // directly).
        //
        // NOTE: Legacy fallback support can be removed once a sufficient transition
        // period has passed and all active core systems ship a plugin with the
        // endpoints. Customers — especially on Windows — tend to update the app very
        // rarely, so keep this fallback for a while.
        property bool useHemsEndpoints: hemsManager !== null
                                        && hemsManager.remoteConnectionEndpointsAvailable
    }

    Connections {
        target: hemsManager
        onSetRemoteConnectionEnabledReply: function(commandId, error) {
            if (commandId !== d.pendingCallId) {
                return;
            }
            d.pendingCallId = -1;
            if (error === "HemsErrorNoError") {
                return;
            }
            var props = {};
            props.errorCode = error;
            var comp = Qt.createComponent("../components/ErrorDialog.qml");
            var popup = comp.createObject(app, props);
            popup.open();
        }
    }

    CoFrostyCard {
        Layout.fillWidth: true
        Layout.topMargin: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        contentTopMargin: Style.smallMargins
        headerText: qsTr("General")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoSwitch {
                id: remoteConnectionSwitch
                Layout.fillWidth: true
                text: qsTr("Remote connection")
                helpText: qsTr("Enabling the remote connection will allow connecting to this %1 from anywhere.").arg(Configuration.deviceName)
                checked: d.useHemsEndpoints
                         ? hemsManager.remoteConnectionEnabled
                         : engine.nymeaConfiguration.tunnelProxyServerConfigurations.count > 0
                enabled: d.useHemsEndpoints ? hemsManager.available : true

                onToggled: {
                    if (d.useHemsEndpoints) {
                        // The remote connection is managed by the energy engine on the core
                        // system (persisted in consolinno.conf and enforced on the tunnel
                        // proxy configuration there). Do not touch the local nymea
                        // configuration here.
                        d.pendingCallId = hemsManager.setRemoteConnectionEnabled(checked)
                    } else {
                        // Legacy fallback for old energy plugins without the remote
                        // connection endpoints. Edit the tunnel proxy configuration
                        // directly. See the note in the `d` object above: remove this
                        // branch after the transition period.
                        if (!checked) {
                            for (let i = 0; i < engine.nymeaConfiguration.tunnelProxyServerConfigurations.count; i++) {
                                let config = engine.nymeaConfiguration.tunnelProxyServerConfigurations.get(i)
                                engine.nymeaConfiguration.deleteTunnelProxyServerConfiguration(config.id)
                            }
                        } else {
                            let config = engine.nymeaConfiguration.createTunnelProxyServerConfiguration(Configuration.defaultTunnelProxyUrl, 2213, true, true, false);
                            engine.nymeaConfiguration.setTunnelProxyServerConfiguration(config)
                        }
                    }
                }
            }
        }
    }

    CoFrostyCard {
        Layout.fillWidth: true
        Layout.topMargin: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        contentTopMargin: Style.smallMargins
        headerText: qsTr("Advanced")
        visible: settings.showHiddenOptions

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoCard {
                Layout.fillWidth: true
                text: qsTr("Connection interfaces")
                interactive: true
                showChildrenIndicator: true
                onClicked: pageStack.push("AdvancedConnectionInterfacesPage.qml")
            }
        }
    }
}
