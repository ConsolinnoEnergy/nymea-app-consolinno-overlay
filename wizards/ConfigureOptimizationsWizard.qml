import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    property HemsManager hemsManager: null

    showNextButton: false
    showBackButton: false

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: Style.margins
        spacing: Style.hugeMargins
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "/ui/images/intro-bg-graphic.svg"
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 300)
            spacing: Style.margins

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font: Style.bigFont
                text: qsTr("Optimizations")
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Please select the desired optimizations:")
            }

            ColumnLayout {
                Layout.fillHeight: true
                CheckBox {
                    id: overloadProtectionCheckBox
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Overload protection")
                    visible: hemsManager.availableUseCases & HemsManager.HemsUseCaseBlackoutProtection
                    checked: visible
                }
                CheckBox {
                    id: smartChargingCheckBox
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Smart charging")
                    visible: hemsManager.availableUseCases & HemsManager.HemsUseCaseCharging
                    checked: visible
                }
                CheckBox {
                    id: smartHeatingCheckBox
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Smart heating")
                    visible: hemsManager.availableUseCases & HemsManager.HemsUseCaseHeating
                    checked: visible
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }


            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("cancel")
                color: Style.yellow
                onClicked: root.done(false, true)
                enabled: false
            }
            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("next")
                color: Style.accentColor
                visible: overloadProtectionCheckBox.checked || smartChargingCheckBox.checked || smartHeatingCheckBox.checked
                onClicked: {
                    if (overloadProtectionCheckBox.checked) {
                        pageStack.push(overloadConfigurationComponent)
                    } else if (smartChargingCheckBox.checked) {
                        pageStack.push(smartChargingConfigurationComponent)
                    } else if (smartHeatingCheckBox.checked) {
                        pageStack.push(smartHeatingConfigurationComponent)
                    } else {
                        root.done(false, false)
                    }
                }
            }
        }
    }

    Component {
        id: overloadConfigurationComponent
        ConsolinnoWizardPageBase {
            id: overloadConfigurationPage
            showNextButton: false
            showBackButton: false

            content: ColumnLayout {
                id: contentColumn
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font: Style.bigFont
                    text: qsTr("Overload protection")
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("Please set your power connection limit:")
                }

                ButtonGroup {
                    id: buttonGroup
                    buttons: buttons.children
                }

                ColumnLayout {
                    id: buttons
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    RadioDelegate {
                        id: limit25
                        Layout.fillWidth: true
                        text: "3 x 25 A"
                        checked: hemsManager.housholdPhaseLimit === value
                        property int value: 25
                    }
                    RadioDelegate {
                        id: limit35
                        Layout.fillWidth: true
                        text: "3 x 35 A"
                        checked: hemsManager.housholdPhaseLimit === value
                        property int value: 35
                    }
                    RadioDelegate {
                        id: limit50
                        Layout.fillWidth: true
                        text: "3 x 50 A"
                        checked: hemsManager.housholdPhaseLimit === value
                        property int value: 50
                    }
                    RadioDelegate {
                        id: limit65
                        Layout.fillWidth: true
                        text: "3 x 65 A"
                        checked: hemsManager.housholdPhaseLimit === value
                        property int value: 65
                    }
                    RadioDelegate {
                        id: limitOther
                        Layout.fillWidth: true
                        text: "other"
                        property int value: parseInt(otherLimit.text)
                        contentItem: TextField {
                            id: otherLimit
                            rightPadding: limitOther.indicator.width + limitOther.spacing
                            validator: IntValidator { bottom: 1; top: 999 }
                            onTextChanged: {
                                limitOther.checked = true
                            }
                        }
                    }
                }


                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("cancel")
                    color: Style.yellow
                    onClicked: root.done(false, true)
                    enabled: false
                }
                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("next")
                    color: Style.accentColor
                    enabled: buttonGroup.checkedButton != null
                    onClicked: {
                        var limit = buttonGroup.checkedButton.value
                        print("limit:", limit)
                        hemsManager.setHousholdPhaseLimit(limit)

                        if (smartChargingCheckBox.checked) {
                            pageStack.push(smartChargingConfigurationComponent)
                        } else if (smartHeatingCheckBox.checked) {
                            pageStack.push(smartHeatingConfigurationComponent)
                        } else {
                            root.done(false, false)
                        }
                    }
                }
            }
        }
    }
    Component {
        id: smartChargingConfigurationComponent
        ConsolinnoWizardPageBase {
            id: smartChargingConfigurationPage
            showNextButton: false
            showBackButton: false

        }
    }
    Component {
        id: smartHeatingConfigurationComponent
        ConsolinnoWizardPageBase {
            id: smartHeatingConfigurationPage
            showNextButton: false
            showBackButton: false

        }
    }
}
