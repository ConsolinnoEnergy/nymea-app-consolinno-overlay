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
                checked: engine.nymeaConfiguration.tunnelProxyServerConfigurations.count > 0

                onToggled: {
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
