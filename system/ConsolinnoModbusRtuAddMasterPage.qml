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
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ModbusRtuManager modbusRtuManager
    property ListModel serialPortBaudrateModel
    property ListModel serialPortParityModel
    property ListModel serialPortDataBitsModel
    property ListModel serialPortStopBitsModel

    header: NymeaHeader {
        text: qsTr("Add a new Modbus RTU master")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    CoFrostyCard {
        id: serialPortsGroup
        Layout.fillWidth: true
        Layout.topMargin: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        contentTopMargin: Style.smallMargins
        headerText: qsTr("Serial ports")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoCard {
                Layout.fillWidth: true
                interactive: false
                text: modbusRtuManager.serialPorts.count !== 0 ?
                          qsTr("Select a serial port.") :
                          qsTr("There are no serial ports available.") + "\n\n" + qsTr("Please make sure the Modbus RTU interface is connected to the system.")
            }

            Repeater {
                id: repeaterModBusRtu
                model: modbusRtuManager.serialPorts
                delegate: CoCard {
                    Layout.fillWidth: true
                    iconLeft: Qt.resolvedUrl("/icons/stock_usb.svg") // #TODO replace
                    showChildrenIndicator: true
                    helpText:  model.description + (model.manufacturer === "" ? "" : " - " + model.manufacturer)
                    text: repeaterModBusRtu.getName(model.systemLocation) + (model.serialNumber === "" ? "" : " - " + model.serialNumber)
                    visible: Configuration.branding === "consolinno" ?
                                 ((model.systemLocation === "/dev/ttymxc3") || (model.systemLocation === "/dev/ttymxc5")) :
                                 true
                    onClicked: {
                        pageStack.push(configureNewModbusRtuMasterPage,
                                       {
                                           modbusRtuManager: modbusRtuManager,
                                           serialPort: modbusRtuManager.serialPorts.get(index)
                                       });
                    }
                }

                function getName(name) {
                    if (name.includes("/dev/ttymxc3")) {
                        return qsTr("RJ45 connector");
                    } else if (name.includes("/dev/ttymxc5")) {
                        return qsTr("14-pin connector");
                    } else {
                        return name;
                    }
                }
            }
        }
    }

    Component {
        id: configureNewModbusRtuMasterPage

        SettingsPageBase {
            id: root

            property ModbusRtuManager modbusRtuManager
            property SerialPort serialPort
            busy: d.pendingCommandId != -1

            header: NymeaHeader {
                text: qsTr("Configure Modbus RTU master")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            QtObject {
                id: d
                property int pendingCommandId: -1

                function addModbusRtuMaster(serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout) {
                    d.pendingCommandId = root.modbusRtuManager.addModbusRtuMaster(serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout)
                }
            }

            Connections {
                target: root.modbusRtuManager
                onAddModbusRtuMasterReply: function(commandId, error, modbusUuid) {
                    if (commandId === d.pendingCommandId) {
                        d.pendingCommandId = -1
                        if (modbusRtuManager.handleModbusError(error)) {
                            pageStack.pop();
                            pageStack.pop();
                        }
                    }
                }
            }

            CoFrostyCard {
                id: serialPortGroup
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Serial port")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        helpText: qsTr("Path")
                        text: repeaterModBusRtu.getName(serialPort.systemLocation)
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        helpText: qsTr("Description")
                        text: serialPort.description.length > 0 ? serialPort.description : qsTr("Unknown")
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        helpText: qsTr("Manufacturer")
                        text: serialPort.manufacturer
                        visible: serialPort.manufacturer !== ""
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        helpText: qsTr("Serialnumber")
                        text: serialPort.serialNumber
                        visible: serialPort.serialNumber !== ""
                        interactive: false
                    }
                }
            }

            CoFrostyCard {
                id: configurationGroup
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Configuration")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoComboBox {
                        id: baudRateComboBox
                        Layout.fillWidth: true
                        labelText: qsTr("Baud rate")
                        enabled: !root.busy
                        model: serialPortBaudrateModel
                        textRole: "value"
                    }

                    CoComboBox {
                        id: parityComboBox
                        Layout.fillWidth: true
                        labelText: qsTr("Parity")
                        enabled: !root.busy
                        model: serialPortParityModel
                        textRole: "text"
                    }

                    CoComboBox {
                        id: dataBitsComboBox
                        Layout.fillWidth: true
                        labelText: qsTr("Data bits")
                        enabled: !root.busy
                        textRole: "text"
                        model: serialPortDataBitsModel
                        Component.onCompleted: {
                            currentIndex = 3
                        }
                    }

                    CoComboBox {
                        id: stopBitsComboBox
                        Layout.fillWidth: true
                        labelText: qsTr("Stop bits")
                        enabled: !root.busy
                        model: serialPortStopBitsModel
                        textRole: "text"
                    }

                    CoInputField {
                        id: numberOfRetriesText
                        Layout.fillWidth: true
                        compactTextField: true
                        labelText: qsTr("Request retries")
                        text: "3"
                        textField.validator: IntValidator { bottom: 0; top: 100 }
                        textField.inputMethodHints: Qt.ImhDigitsOnly
                    }

                    CoInputField {
                        id: timeoutText
                        Layout.fillWidth: true
                        compactTextField: true
                        labelText: qsTr("Request timeout")
                        text: "100"
                        unit: qsTr("ms")
                        textField.inputMethodHints: Qt.ImhDigitsOnly
                        textField.validator: IntValidator { bottom: 10; top: 100000 }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                Layout.topMargin: Style.margins
                text: qsTr("Add")
                enabled: !root.busy
                onClicked: {
                    var baudrate = serialPortBaudrateModel.get(baudRateComboBox.currentIndex).value;
                    var parity = serialPortParityModel.get(parityComboBox.currentIndex).value;
                    var dataBits = serialPortDataBitsModel.get(dataBitsComboBox.currentIndex).value;
                    var stopBits = serialPortStopBitsModel.get(stopBitsComboBox.currentIndex).value;
                    var numberOfRetries = numberOfRetriesText.text;
                    var timeout = timeoutText.text;
                    d.addModbusRtuMaster(serialPort.systemLocation,
                                         baudrate,
                                         parity,
                                         dataBits,
                                         stopBits,
                                         numberOfRetries,
                                         timeout);
                }
            }
        }
    }
}
