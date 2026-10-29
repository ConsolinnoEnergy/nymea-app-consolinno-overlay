import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("Look and feel")

    Connections {
        target: styleController
        function onCurrentStyleChanged() {
            var popup = styleChangedDialog.createObject(root)
            popup.open()
        }
    }

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: appearanceGroup
            Layout.fillWidth: true
            headerText: qsTr("Appearance")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoComboBox {
                    id: styleComboBox
                    Layout.fillWidth: true
                    model: ListModel { id: stylesModel }
                    labelText: qsTr("Style")
                    textRole: "text"
                    valueRole: "value"
                    Component.onCompleted: {
                        stylesModel.append({ value: "light", text: qsTr("Light") });
                        if (Configuration.branding === "consolinno") {
                            stylesModel.append({ value: "dark", text: qsTr("Dark") });
                            stylesModel.append({ value: "auto", text: qsTr("Automatic") });
                        }
                        currentIndex = comboBox.indexOfValue(styleController.rawCurrentStyle)
                    }
                    comboBox.onActivated: styleController.currentStyle = currentValue
                }

                CoComboBox {
                    id: viewModeComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("View mode")
                    visible: false // !kioskMode && Qt.platform.os !== "ios"
                    model: [qsTr("Windowed"), qsTr("Maximized"), qsTr("Fullscreen"), qsTr("Automatic")]
                    currentIndex: {
                        switch (settings.viewMode) {
                        case ApplicationWindow.Windowed:
                            return 0;
                        case ApplicationWindow.Maximized:
                            return 1;
                        case ApplicationWindow.FullScreen:
                            return 2;
                        case ApplicationWindow.AutomaticVisibility:
                            return 3;
                        }
                    }

                    comboBox.onActivated: {
                        switch (currentIndex) {
                        case 0:
                            settings.viewMode = ApplicationWindow.Windowed;
                            break;
                        case 1:
                            settings.viewMode = ApplicationWindow.Maximized;
                            break;
                        case 2:
                            settings.viewMode = ApplicationWindow.FullScreen;
                            break;
                        case 3:
                            settings.viewMode = ApplicationWindow.AutomaticVisibility;
                            break;
                        }
                    }
                }
            }
        }

        CoFrostyCard {
            id: regionalGroup
            Layout.fillWidth: true
            headerText: qsTr("Regional")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoComboBox {
                    id: unitSystemComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Unit system")
                    model: [ qsTr("Metric"), qsTr("Imperial") ]
                    currentIndex: settings.units === "metric" ? 0 : 1
                    comboBox.onActivated: function(index) {
                        settings.units = index === 0 ? "metric" : "imperial";
                    }
                }
            }
        }

        CoFrostyCard {
            id: behaviorGroup
            Layout.fillWidth: true
            headerText: qsTr("Behavior")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoSwitch {
                    id: returnToHomeCheckBox
                    Layout.fillWidth: true
                    text: qsTr("Return to home on idle")
                    checked: settings.returnToHome
                    onClicked: settings.returnToHome = checked
                }

                CoSwitch {
                    id: screenOffCheckBox
                    Layout.fillWidth: true
                    text: qsTr("Turn screen off when idle")
                    visible: PlatformHelper.canControlScreen
                    checked: PlatformHelper.screenTimeout > 0
                    onClicked: PlatformHelper.screenTimeout = (checked ? 15000 : 0)
                }

                CoInputStepper {
                    id: screenOffTimeoutStepper
                    Layout.fillWidth: true
                    visible: PlatformHelper.screenTimeout > 0
                    labelText: qsTr("Screen off timeout")
                    unit: qsTr("seconds")
                    compact: true
                    value: PlatformHelper.screenTimeout / 1000
                    onValueModified: function(value) {
                        PlatformHelper.screenTimeout = value * 1000
                    }
                }

                CoSlider {
                    id: screenBrightnessSlider
                    Layout.fillWidth: true
                    visible: PlatformHelper.canControlScreen
                    labelText: qsTr("Screen brightness")
                    valueText: value + " %"
                    value: PlatformHelper.screenBrightness
                    onMoved: PlatformHelper.screenBrightness = value
                    from: 0
                    to: 100
                    stepSize: 1
                }
            }
        }
    }

    Component {
        id: styleChangedDialog
        Dialog {
            width: Math.min(parent.width * .8, Math.max(contentLabel.implicitWidth, 300))
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true

            title: qsTr("Style changed")

            standardButtons: Dialog.Ok

            ColumnLayout {
                id: content
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Label {
                    id: contentLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr("The application needs to be restarted for style changes to take effect.")
                }
            }
        }
    }
}
