import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import Nymea 1.0

SettingsPageBase {
    id: root

    property ModbusRtuManager modbusRtuManager
    property ModbusRtuMaster modbusRtuMaster
    property SerialPort serialPort: modbusRtuManager.serialPorts.find(modbusRtuMaster.serialPort)

    property ListModel serialPortBaudrateModel
    property ListModel serialPortParityModel
    property ListModel serialPortDataBitsModel
    property ListModel serialPortStopBitsModel


    busy: d.pendingCommandId != -1

    header: NymeaHeader {
        text: qsTr("Reconfigure Modbus RTU master")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCommandId: -1

        function reconfigureModbusRtuMaster(modbusUuid, serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout) {
            d.pendingCommandId = root.modbusRtuManager.reconfigureModbusRtuMaster(modbusUuid, serialPort, baudRate, parity, dataBits, stopBits, numberOfRetries, timeout)
        }
    }

    Connections {
        target: root.modbusRtuManager
        onReconfigureModbusRtuMasterReply: function(commandId, error) {
            if (commandId === d.pendingCommandId) {
                d.pendingCommandId = -1
                if (modbusRtuManager.handleModbusError(error)) {
                    pageStack.pop();
                    pageStack.pop();
                }
            }
        }
    }

    function getName(name){
        if(name.includes("/dev/ttymxc3")){
            return qsTr("RJ45 connector")
        }else if(name.includes("/dev/ttymxc5")){
            return qsTr("14-pin connector")
        }else{
            return name;
        }
    }


    CoFrostyCard {
        id: infoGroup
        Layout.fillWidth: true
        Layout.topMargin: Style.margins
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        contentTopMargin: Style.smallMargins
        headerText: qsTr("Information")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoCard {
                Layout.fillWidth: true
                helpText: qsTr("UUID")
                text: modbusRtuMaster.modbusUuid
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
                text: root.getName(serialPort.systemLocation)
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
                Component.onCompleted: {
                    for (var i = 0; i < serialPortBaudrateModel.count; i++) {
                        if (serialPortBaudrateModel.get(i).value === modbusRtuMaster.baudrate) {
                            currentIndex = i;
                        }
                    }
                }
            }

            CoComboBox {
                id: parityComboBox
                Layout.fillWidth: true
                labelText: qsTr("Parity")
                enabled: !root.busy
                model: serialPortParityModel
                textRole: "text"
                Component.onCompleted: {
                    for (var i = 0; i < serialPortParityModel.count; i++) {
                        if (serialPortParityModel.get(i).value === modbusRtuMaster.parity) {
                            currentIndex = i;
                        }
                    }
                }
            }

            CoComboBox {
                id: dataBitsComboBox
                Layout.fillWidth: true
                labelText: qsTr("Data bits")
                enabled: !root.busy
                textRole: "text"
                model: serialPortDataBitsModel
                Component.onCompleted: {
                    for (var i = 0; i < serialPortDataBitsModel.count; i++) {
                        if (serialPortDataBitsModel.get(i).value === modbusRtuMaster.dataBits) {
                            currentIndex = i;
                        }
                    }
                }
            }

            CoComboBox {
                id: stopBitsComboBox
                Layout.fillWidth: true
                labelText: qsTr("Stop bits")
                enabled: !root.busy
                model: serialPortStopBitsModel
                textRole: "text"
                Component.onCompleted: {
                    for (var i = 0; i < serialPortStopBitsModel.count; i++) {
                        if (serialPortStopBitsModel.get(i).value === modbusRtuMaster.stopBits) {
                            currentIndex = i;
                        }
                    }
                }
            }

            CoInputField {
                id: numberOfRetriesText
                Layout.fillWidth: true
                compactTextField: true
                labelText: qsTr("Request retries")
                text: "3"
                textField.validator: IntValidator { bottom: 0; top: 100 }
                textField.inputMethodHints: Qt.ImhDigitsOnly
                Component.onCompleted: {
                    numberOfRetriesText.text = modbusRtuMaster.numberOfRetries;
                }
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
                Component.onCompleted: {
                    timeoutText.text = modbusRtuMaster.timeout;
                }
            }
        }
    }

    Button {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        Layout.topMargin: Style.margins
        text: qsTr("Apply")
        enabled: !root.busy
        onClicked: {
            var baudrate = serialPortBaudrateModel.get(baudRateComboBox.currentIndex).value;
            var parity = serialPortParityModel.get(parityComboBox.currentIndex).value;
            var dataBits = serialPortDataBitsModel.get(dataBitsComboBox.currentIndex).value;
            var stopBits = serialPortStopBitsModel.get(stopBitsComboBox.currentIndex).value;
            var numberOfRetries = numberOfRetriesText.text;
            var timeout = timeoutText.text;
            d.reconfigureModbusRtuMaster(modbusRtuMaster.modbusUuid,
                                         serialPort.systemLocation,
                                         baudrate,
                                         parity,
                                         dataBits,
                                         stopBits,
                                         numberOfRetries,
                                         timeout);
        }
    }

}
