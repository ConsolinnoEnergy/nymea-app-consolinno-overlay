import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root

    headerText: qsTr("General settings")
    busy: d.pendingCommand !== -1

    QtObject {
        id: d
        property int pendingCommand: -1
    }

    function compareSemanticVersions(version1, version2) {
        // Returns 0 if version1 == version2
        // Returns 1 if version1 > version2
        // Returns -1 if version1 < version2

        var v1 = version1.split('.').map(function(part) { return parseInt(part); });
        var v2 = version2.split('.').map(function(part) { return parseInt(part); });

        for (var i = 0; i < Math.max(v1.length, v2.length); i++) {
            var num1 = i < v1.length ? v1[i] : 0;
            var num2 = i < v2.length ? v2[i] : 0;

            if (num1 < num2) {
                return -1; // version1 is lower
            } else if (num1 > num2) {
                return 1; // version1 is higher
            }
        }

        return 0; // versions are equal
    }
    
    function checkHEMSVersion(){
        var minSysVersion = Configuration.minSysVersion
        // Checks if System version is less or equal to minSysVersion
        if ([-1].includes(compareSemanticVersions(engine.jsonRpcClient.experiences.Hems, minSysVersion)))
        {
            return false
        }
        return true
    }

    Connections {
        target: engine.systemController
        function onRestartReply(id, success) { handleReply(id, success) }
        function onRebootReply(id, success) { handleReply(id, success) }
        function onShutdownReply(id, success) { handleReply(id, success) }
        function handleReply(id, success) {
            if (id === d.pendingCommand) {
                d.pendingCommand = -1
                if (!success) {
                    var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                    var popup = component.createObject(root);
                    popup.open()
                }
            }
        }
    }

    Connections {
        target: hemsManager
        onFactoryResetReply: function(commandId, error) {
            if (commandId == d.pendingCommand) {
                d.pendingCommand = -1

                var props = {};
                if (error !== "HemsErrorNoError") {
                    props.errorCode = error;
                    var comp = Qt.createComponent("../components/ErrorDialog.qml")
                    var popup = comp.createObject(app, props)
                    popup.open();
                }
            }
        }
    }

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: generalGroup
            Layout.fillWidth: true
            headerText: qsTr("General")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoInputField {
                    id: nameInput
                    Layout.fillWidth: true
                    labelText: qsTr("Name")
                    text: engine.nymeaConfiguration.serverName
                }

                Button {
                    id: applyNameButton
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.smallMargins
                    text: qsTr("Apply changes")
                    enabled: nameInput.displayText !== engine.nymeaConfiguration.serverName
                    onClicked: {
                        engine.nymeaConfiguration.serverName = nameInput.displayText
                    }
                }
            }
        }

        CoFrostyCard {
            id: dateAndTimeGroup
            Layout.fillWidth: true
            headerText: qsTr("Date and time")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoSwitch {
                    id: autoDateTimeSwitch
                    Layout.fillWidth: true
                    visible: engine.jsonRpcClient.ensureServerVersion("4.1") && engine.systemController.automaticTimeAvailable
                    text: qsTr("Set date and time automatically")
                    checked: engine.systemController.automaticTime
                    onClicked: {
                        engine.systemController.automaticTime = checked
                    }
                }

                CoCard {
                    id: dateCard
                    Layout.fillWidth: true
                    visible: engine.jsonRpcClient.ensureServerVersion("4.1")
                    text: engine.systemController.serverTime.toLocaleDateString()
                    labelText: qsTr("Date")
                    interactive: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
                    showChildrenIndicator: interactive
                    onClicked: {
                        var comp = Qt.createComponent(Qt.resolvedUrl("../components/CoPeriodPickerOverlay.qml"));
                        var datePicker = comp.createObject(app,
                                                           {
                                                               selectedDate: engine.systemController.serverTime,
                                                               minDate: new Date(1970, 1, 1)
                                                           });
                        datePicker.open();
                        datePicker.dateChosen.connect(function(date) {
                            var newDate = new Date(engine.systemController.serverTime)
                            newDate.setFullYear(date.getFullYear())
                            newDate.setMonth(date.getMonth())
                            newDate.setDate(date.getDate())
                            engine.systemController.serverTime = newDate;
                        })
                    }
                }

                CoCard {
                    id: timeCard
                    Layout.fillWidth: true
                    visible: engine.jsonRpcClient.ensureServerVersion("4.1")
                    text: engine.systemController.serverTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    labelText: qsTr("Time")
                    interactive: !engine.systemController.automaticTime && engine.systemController.timeManagementAvailable
                    showChildrenIndicator: interactive
                    onClicked: {
                        var comp = Qt.createComponent(Qt.resolvedUrl("../components/CoTimePickerOverlay.qml"));
                        var title = qsTr("Choose time")
                        var timePicker = comp.createObject(app,
                                                           {
                                                               title: title,
                                                               initialHours: engine.systemController.serverTime.getHours(),
                                                               initialMinutes: engine.systemController.serverTime.getMinutes(),
                                                               quarterHours: false,
                                                               includeMidnightHour: false
                                                           });
                        timePicker.open();
                        timePicker.timeChosen.connect(function(hours, minutes) {
                            var date = new Date(engine.systemController.serverTime)
                            date.setHours(hours);
                            date.setMinutes(minutes)
                            engine.systemController.serverTime = date;
                        })
                    }
                }

                CoComboBox {
                    id: timeZoneComboBox
                    Layout.fillWidth: true
                    visible: engine.jsonRpcClient.ensureServerVersion("4.1")
                    labelText: qsTr("Time zone")
                    model: engine.systemController.timeZones
                    currentIndex: model.indexOf(engine.systemController.serverTimeZone)
                    comboBox.onActivated: function(index) {
                        engine.systemController.serverTimeZone = currentText;
                    }
                }
            }
        }

        CoFrostyCard {
            id: systemGroup
            Layout.fillWidth: true
            headerText: qsTr("System")
            contentTopMargin: Style.margins
            visible: engine.jsonRpcClient.ensureServerVersion("9.0") || engine.systemController.powerManagementAvailable

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Style.smallMargins

                Button {
                    id: restartButton
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.smallMargins
                    text: qsTr("Restart %1").arg(Configuration.systemName)
                    visible: engine.systemController.powerManagementAvailable && engine.jsonRpcClient.ensureServerVersion("5.1") && !Configuration.hideRestartButton
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                        var text = qsTr("Are you sure you want to restart %1 now?").arg(Configuration.systemName)
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                            title: qsTr("Restart %1").arg(Configuration.systemName),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            d.pendingCommand = engine.systemController.restart()
                        })
                    }
                }

                Button {
                    id: rebootButton
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.smallMargins
                    text: qsTr("Reboot %1").arg(Configuration.systemName)
                    visible: engine.systemController.powerManagementAvailable && !Configuration.hideRebootButton
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                        var text = qsTr("Are you sure you want to reboot %1 now?").arg(Configuration.systemName)
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                            title: qsTr("Reboot %1 system").arg(Configuration.systemName),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            d.pendingCommand = engine.systemController.reboot()
                        })
                    }
                }

                Button {
                    id: shutdownButton
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.smallMargins
                    text: qsTr("Shut down %1").arg(Configuration.systemName)
                    visible: engine.systemController.powerManagementAvailable && !Configuration.hideShutdownButton
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                        var text = qsTr("Are you sure you want to shut down %1 now?").arg(Configuration.systemName)
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                            title: qsTr("Shut down %1 system").arg(Configuration.systemName),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            d.pendingCommand = engine.systemController.shutdown()
                        })
                    }
                }

                Button {
                    id: factorySettings
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    Layout.bottomMargin: Style.smallMargins
                    text: qsTr("Reset to factory settings")
                    visible: checkHEMSVersion() && !Configuration.hideFactoryResetButton && hemsManager.available
                    onClicked: {
                        var popup = factoryResetDialogComponent.createObject(app);
                        popup.open();
                        popup.accepted.connect(function() {
                            d.pendingCommand = hemsManager.factoryReset()
                        })
                    }
                }
            }
        }
    }

    Component {
        id: factoryResetDialogComponent
        NymeaDialog {
            id: factoryResetDialog
            title: qsTr("Reset to factory settings")
            standardButtons: Dialog.Ok | Dialog.Cancel

            ColumnLayout {
                width: parent.width
                spacing: app.margins

                RowLayout {
                    Layout.fillWidth: true
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("The factory reset restores all software settings to their factory defaults, thereby deleting all device settings, commissioning settings and data.")
                        wrapMode: Text.WordWrap
                    }
                }

                CheckBox {
                    id: confirmCheckBox
                    Layout.fillWidth: true
                    text: qsTr("I have read the message.")

                    contentItem: Item {
                        implicitWidth: confirmCheckBoxLabel.implicitWidth + confirmCheckBox.indicator.width + confirmCheckBox.spacing
                        implicitHeight: confirmCheckBoxLabel.implicitHeight

                        Label {
                            id: confirmCheckBoxLabel
                            anchors {
                                left: parent.left
                                leftMargin: confirmCheckBox.indicator.width + confirmCheckBox.spacing
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            text: confirmCheckBox.text
                            font: confirmCheckBox.font
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            onAccepted: {
                // Will be handled by connection in parent
            }

            Component.onCompleted: {
                standardButton(Dialog.Ok).enabled = Qt.binding(function() { return confirmCheckBox.checked })
            }
        }
    }
}
