/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15
import "../components"
import Nymea 1.0

Page {
    id: root
    property bool settingsWizard: true
    signal done(bool skip, bool abort);

    header: NymeaHeader {
        text: qsTr("Modbus-RTU-Interfaces")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/add.svg"
            text: qsTr("Add Modbus RTU master")
            onClicked: pageStack.push(Qt.resolvedUrl("ConsolinnoModbusRtuAddMasterPage.qml"), {
                                          modbusRtuManager: modbusRtuManager,
                                          serialPortBaudrateModel: serialPortBaudrateModel,
                                          serialPortParityModel: serialPortParityModel,
                                          serialPortDataBitsModel: serialPortDataBitsModel,
                                          serialPortStopBitsModel: serialPortStopBitsModel })
            enabled: modbusRtuManager.supported
        }
    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins;

        ModbusRtuManager {
            id: modbusRtuManager
            engine: _engine

            function handleModbusError(error) {
                var props = {};
                switch (error) {
                case "ModbusRtuErrorNoError":
                    return true;
                case "ModbusRtuErrorNotAvailable":
                    props.text = qsTr("The serial port is not available any more.");
                    break;
                case "ModbusRtuErrorNotSupported":
                    props.text = qsTr("Modbus is not supported on this platform.");
                    break;
                case "ModbusRtuErrorHardwareNotFound":
                    props.text = qsTr("The Modbus RTU hardware could not be found.");
                    break;
                case "ModbusRtuErrorUuidNotFound":
                    props.text = qsTr("The selected Modbus RTU master does not exist any more.");
                    break;
                case "ModbusRtuErrorConnectionFailed":
                    props.text = qsTr("Unable to connect to the Modbus RTU master.\n\nMaybe the hardware is already in use.");
                    break;
                case "ModbusRtuInvalidTimeoutValue":
                    props.text = qsTr("The specified timeout value is not valid.\n\nUse a timeout value greater or equal to 10 ms.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();

                return false;
            }
        }

        ListModel {
            id: serialPortBaudrateModel
            ListElement { value: 9600; }
            ListElement { value: 14400; }
            ListElement { value: 19200; }
            ListElement { value: 38400; }
            ListElement { value: 57600; }
            ListElement { value: 115200; }
            ListElement { value: 128000; }
            ListElement { value: 230400; }
            ListElement { value: 256000; }

            function getText(baudrate) {
                for (var index = 0; index < serialPortBaudrateModel.count; index++) {
                    if (serialPortBaudrateModel.get(index).value === baudrate) {
                        return serialPortBaudrateModel.get(index).value
                    }
                }

                return qsTr("Unknown baud rate")
            }
        }

        ListModel {
            id: serialPortParityModel
            ListElement { value: SerialPort.SerialPortParityNoParity; text: qsTr("No parity") }
            ListElement { value: SerialPort.SerialPortParityEvenParity; text: qsTr("Even parity") }
            ListElement { value: SerialPort.SerialPortParityOddParity; text: qsTr("Odd parity") }
            ListElement { value: SerialPort.SerialPortParitySpaceParity; text: qsTr("Space parity") }
            ListElement { value: SerialPort.SerialPortParityMarkParity; text: qsTr("Mark parity") }

            function getText(parity) {
                for (var index = 0; index < serialPortParityModel.count; index++) {
                    if (serialPortParityModel.get(index).value === parity) {
                        return serialPortParityModel.get(index).text
                    }
                }

                return qsTr("Unknown parity")
            }
        }

        ListModel {
            id: serialPortDataBitsModel
            ListElement { value: SerialPort.SerialPortDataBitsData5; text: qsTr("5 data bits") }
            ListElement { value: SerialPort.SerialPortDataBitsData6; text: qsTr("6 data bits") }
            ListElement { value: SerialPort.SerialPortDataBitsData7; text: qsTr("7 data bits") }
            ListElement { value: SerialPort.SerialPortDataBitsData8; text: qsTr("8 data bits") }

            function getText(dataBits) {
                for (var index = 0; index < serialPortDataBitsModel.count; index++) {
                    if (serialPortDataBitsModel.get(index).value === dataBits) {
                        return serialPortDataBitsModel.get(index).text
                    }
                }

                return qsTr("Unknown data bits")
            }
        }

        ListModel {
            id: serialPortStopBitsModel
            ListElement { value: SerialPort.SerialPortStopBitsOneStop; text: qsTr("One stop bit") }
            ListElement { value: SerialPort.SerialPortStopBitsOneAndHalfStop; text: qsTr("One and a half stop bits") }
            ListElement { value: SerialPort.SerialPortStopBitsTwoStop; text: qsTr("Two stop bits") }

            function getText(stopBits) {
                for (var index = 0; index < serialPortStopBitsModel.count; index++) {
                    if (serialPortStopBitsModel.get(index).value === stopBits) {
                        return serialPortStopBitsModel.get(index).text
                    }
                }

                return qsTr("Unknown stop bits")
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.topMargin: 20
                Layout.preferredWidth: app.width - 2* Style.margins
                text: qsTr("Note: If you intend to connect a device via <b>Modbus-RTU</b>, please verify the Modbus interface settings to ensure they are compatible with the connected device. If you wish to use a different interface, please add another one.")
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                Layout.topMargin: 10
                Layout.preferredWidth: app.width - 2* Style.margins
                wrapMode: Text.WordWrap
                text: qsTr("Available interfaces:")
            }

            VerticalDivider
            {
                Layout.preferredWidth: app.width - 2* Style.margins
                dividerColor: Material.accent
            }

            Flickable {
                id: modBusFlickable
                clip: true
                width: parent.width
                height: parent.height
                contentHeight: modBusFlickable.height
                contentWidth: app.width


                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: app.height/3
                Layout.preferredWidth: app.width - 2* Style.margins
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: repeaterName
                    Layout.preferredWidth: app.width - 2* Style.margins
                    Layout.fillHeight: true

                    Repeater {
                        enabled: modbusRtuManager.supported
                        model: modbusRtuManager.modbusRtuMasters
                        delegate: NymeaSwipeDelegate {
                            Layout.preferredWidth: app.width - 2* Style.margins
                            iconName: "../images/modbus.svg"
                            text: repeaterName.getName(model.serialPort) + " " + model.baudrate
                            subText: model.connected ? qsTr("Connected") : qsTr("Disconnected")
                            onClicked: pageStack.push(modbusDetailsComponent, { modbusRtuManager: modbusRtuManager, modbusRtuMaster: modbusRtuManager.modbusRtuMasters.get(index) })
                        }
                    }


                    Label {
                        Layout.preferredWidth: app.width - 2* Style.margins
                        Layout.topMargin: 10;
                        wrapMode: Text.WordWrap
                        text: qsTr("Modbus-RTU is not supported on this platform.")
                        visible: !modbusRtuManager.supported
                    }

                    Label {
                        Layout.preferredWidth: app.width - 2* Style.margins
                        Layout.topMargin: 10;
                        wrapMode: Text.WordWrap
                        text: qsTr("No devices discovered") //Keine Geräte entdeckt
                        visible: modbusRtuManager.modbusRtuMasters.count === 0
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

                }

            }

            VerticalDivider
            {
                Layout.preferredWidth: app.width - 2* Style.margins
                dividerColor: Material.accent
            }

        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 0
            visible: settingsWizard
            Layout.bottomMargin: 25
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: btnCancel
                text: qsTr("cancel")
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                onClicked: root.done(false, true, false)
            }

            Button {
                id: nextStepButton
                text: qsTr("Next step")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                Layout.preferredWidth: 200
                Layout.preferredHeight: btnCancel.height - 9
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                contentItem:Row{
                    Text{
                        id: nextStepButtonText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: nextStepButton.text
                        font: nextStepButton.font
                        opacity: enabled ? 1.0 : 0.3
                        color: Style.consolinnoHighlightForeground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image{
                        id: headerImage
                        anchors.right : parent.right
                        anchors.verticalCenter:  parent.verticalCenter

                        sourceSize.width: 18
                        sourceSize.height: 18
                        source: "../images/next.svg"

                        layer{
                            enabled: true
                            effect: ColorOverlay{
                                color: Style.consolinnoHighlightForeground
                            }
                        }
                    }
                }

                background: Rectangle{
                    height: parent.height
                    width: parent.width
                    border.color: Material.background
                    color: Configuration.secondButtonColor
                    radius: 4
                }
                onClicked: root.done(true, false, false)
            }
        }

    }

    Component {
        id: modbusDetailsComponent

        SettingsPageBase {
            id: root

            property ModbusRtuManager modbusRtuManager
            property ModbusRtuMaster modbusRtuMaster

            busy: d.pendingCommandId !== -1

            header: NymeaHeader {
                text: qsTr("Modbus-RTU-Interface")
                backButtonVisible: true
                onBackPressed: pageStack.pop()

                HeaderButton {
                    imageSource: "../images/delete.svg"
                    text: qsTr("Remove Modbus RTU Interface")
                    enabled: modbusRtuManager.supported
                    onClicked: {
                        var dialog = removeModbusMasterDialogComponent.createObject(app, {modbusRtuMaster: root.modbusRtuMaster})
                        dialog.open()
                    }
                }
            }

            Component {
                id: removeModbusMasterDialogComponent

                NymeaDialog {
                    id: removeModbusMasterDialog

                    property ModbusRtuMaster modbusRtuMaster

                    headerIcon: "../images/modbus.svg"
                    title: qsTr("Remove Modbus RTU Interface")
                    text: qsTr("Are you sure you want to remove this Modbus RTU Interface?")
                    standardButtons: Dialog.Ok | Dialog.Cancel

                    Label {
                        text: qsTr("Please note that all related things will stop working until you assign a new Modbus RTU Interface to them.")
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    onAccepted: {
                        d.removeModbusRtuMaster(modbusRtuMaster.modbusUuid)
                    }
                }
            }

            QtObject {
                id: d
                property int pendingCommandId: -1

                function removeModbusRtuMaster(modbusUuid) {
                    d.pendingCommandId = root.modbusRtuManager.removeModbusRtuMaster(modbusUuid)
                }
            }

            Connections {
                target: root.modbusRtuManager
                onRemoveModbusRtuMasterReply: {
                    if (commandId === d.pendingCommandId) {
                        d.pendingCommandId = -1
                        if (modbusRtuManager.handleModbusError(error)) {
                            // FIXME: the page does not work if I pop the page here
                            pageStack.pop()
                        }
                    }
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Information")
            }

//            RowLayout {
//                Layout.fillWidth: true

//                Led {
//                    Layout.preferredHeight: Style.iconSize
//                    Layout.preferredWidth: Style.iconSize
//                    state: modbusRtuMaster ? (modbusRtuMaster.connected ? "on" : "red") : "red"
//                }

//                Label {
//                    Layout.fillWidth: true
//                    text: modbusRtuMaster ? (modbusRtuMaster.connected ? qsTr("Connected") : qsTr("Disconnected")) : qsTr("Disconnected")
//                }
//            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Connection status")
                subText: modbusRtuMaster && modbusRtuMaster.connected ? qsTr("Connected") : qsTr("Disconnected")
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("UUID")
                subText: modbusRtuMaster ? modbusRtuMaster.modbusUuid : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Path")
                subText: modbusRtuMaster ? modbusRtuMaster.serialPort : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Baud rate")
                subText: modbusRtuMaster ? serialPortBaudrateModel.getText(modbusRtuMaster.baudrate) : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Parity")
                subText: modbusRtuMaster ? serialPortParityModel.getText(modbusRtuMaster.parity) : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Data bits")
                subText: modbusRtuMaster ? serialPortDataBitsModel.getText(modbusRtuMaster.dataBits) : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Stop bits")
                subText: modbusRtuMaster ? serialPortStopBitsModel.getText(modbusRtuMaster.stopBits) : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Request retries")
                subText: modbusRtuMaster ? modbusRtuMaster.numberOfRetries : ""
                progressive: false
                prominentSubText: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Request timeout [ms]")
                subText: modbusRtuMaster ? modbusRtuMaster.timeout + " ms" : ""
                progressive: false
                prominentSubText: false
            }

            Button {
                id: reconfigureButton
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Reconfigure")
                enabled: !root.busy
                onClicked: pageStack.push(Qt.resolvedUrl("ModbusRtuReconfigureMasterPage.qml"), {
                                              modbusRtuManager: modbusRtuManager,
                                              modbusRtuMaster: root.modbusRtuMaster,
                                              serialPortBaudrateModel: serialPortBaudrateModel,
                                              serialPortParityModel: serialPortParityModel,
                                              serialPortDataBitsModel: serialPortDataBitsModel,
                                              serialPortStopBitsModel: serialPortStopBitsModel
                                          })
            }
        }
    }


}
