import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "qrc:/ui/components"
import "../delegates"

Page {
    id: root
    property HemsManager hemsManager
    property int directionID: 0

    signal done(bool skip, bool abort, bool back)

    header: NymeaHeader {
        text: qsTr("Blackout protection")
        backButtonVisible: true
        onBackPressed:{
            if (directionID == 0)
            {
                pageStack.pop()
            }else{
                root.done(false, false, true)
            }

        }
    }

    property int phaseLimit: 25
    property int configuredPhaseLimit: 25
    property bool settingsChanged: phaseLimit != configuredPhaseLimit

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onHousholdPhaseLimitChanged: {
            configuredPhaseLimit = housholdPhaseLimit
        }

        onSetHousholdPhaseLimitReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1

                var props = {};
                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return;
                case "HemsErrorInvalidPhaseLimit":
                    props.text = qsTr("Invalid phase limit.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    // TODO: maybe allow to disable, or prioritize which ev charger should be adjusted first or something like that
    /*
    // Houshold phase limit [A]
    ColumnLayout {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins


        RadioDelegate {
            id: limit25
            Layout.fillWidth: true
            text: "3 x 25 A"
            onClicked: phaseLimit = 25
        }
        RadioDelegate {
            id: limit35
            Layout.fillWidth: true
            text: "3 x 35 A"
            onClicked: phaseLimit = 35
        }
        RadioDelegate {
            id: limit40
            Layout.fillWidth: true
            text: "3 x 40 A"
            onClicked: phaseLimit = 40
        }
        RadioDelegate {
            id: limit50
            Layout.fillWidth: true
            text: "3 x 50 A"
            onClicked: phaseLimit = 50
        }
        RadioDelegate {
            id: limit63
            Layout.fillWidth: true
            text: "3 x 63 A"
            onClicked: phaseLimit = 63
        }
        RadioDelegate {
            id: limitOther
            Layout.fillWidth: true
            text: "other"

            contentItem: RowLayout {
              Label {
                text: "3 x A:"
              }
              TextField {
                id: otherLimit
                rightPadding: 50//otherDelegate.width - otherDelegate.indicator.width - otherDelegate.spacing
                placeholderText: "16 - 100"
                onTextChanged: {
                    limitOther.checked = true
                    phaseLimit = parseInt(text)
                }
                validator: RegExpValidator {
                    regExp: /^(1[6-9]|[2-9][0-9]|100)$/
                }
                inputMethodHints: Qt.ImhDigitsOnly
              }
            }
            onClicked: phaseLimit = otherLimit.text
        }


        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont

        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            enabled: phaseLimit > 15
            text: qsTr("Save")

            onClicked: {
                // TODO: wait for response
                // for debugging purposes or to let the user know that some values are not valid
                //footer.text = "clicked"

                if(directionID === 0){
                    d.pendingCallId = hemsManager.setHousholdPhaseLimit(root.phaseLimit)
                }
                else if(directionID === 1)
                {
                    hemsManager.setHousholdPhaseLimit(root.phaseLimit)
                    root.done(false, false, false)
                }

            }

        }

        Item {
            // place holder
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Component.onCompleted: {
            phaseLimit = hemsManager.housholdPhaseLimit
            configuredPhaseLimit = hemsManager.housholdPhaseLimit
            switch (configuredPhaseLimit) {
            case 25:
                limit25.checked = true
                break
            case 35:
                limit35.checked = true
                break
            case 40:
                limit40.checked = true
                break
            case 50:
                limit50.checked = true
                break
            case 63:
                limit63.checked = true
                break
            default:
                limitOther.checked = true
                otherLimit.text = configuredPhaseLimit
                break
            }
        }
    }
    */

    ColumnLayout {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

        RowLayout {
            Layout.bottomMargin: 0
            CheckBox {
                id: checkBox
                text: qsTr("Load management:")
            }

            InfoButton {
                Layout.fillWidth: true
                Layout.bottomMargin: 15
                push: "BlackOutProtectionInfo.qml"
            }
        }

        RowLayout {
            visible: !checkBox.checked
            Layout.topMargin: 50
            Layout.alignment: Qt.AlignCenter

            Label {
                text: qsTr("The overload protection is not activated.")
            }
        }

        ColumnLayout {
            visible: checkBox.checked

            RowLayout {

                Label {
                    Layout.rightMargin: 28
                    text: qsTr("Phasen")
                }

                ComboBox {
                    Layout.fillWidth: true
                    textRole: "key"
                    model:  ListModel {
                        ListElement { key: qsTr("1 Phase"); value: 1}
                        ListElement { key: qsTr("2 Phasen"); value: 2}
                        ListElement { key: qsTr("3 Phasen"); value: 3}
                    }
                }
            }

            RowLayout {

                SelectionTabs {
                    id: selectionTabs
                    Layout.fillWidth: true
                    Layout.topMargin: 30
                    visible: true
                    currentIndex: 0
                    model: ListModel {
                        ListElement {
                            modelData: qsTr("Nominal current")
                        }
                        ListElement {
                            modelData: qsTr("Power")
                        }
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 20
                Layout.bottomMargin: 0
                visible: selectionTabs.currentIndex === 0
                spacing: 0

                TextField {
                  id: nominalCurrent
                  Layout.preferredWidth: 70
                  Layout.rightMargin: 20
                  placeholderText: "16 - 100"
                  onTextChanged: {
                      phaseLimit = parseInt(nominalCurrent.text)
                  }
                  validator: RegExpValidator {
                      regExp: /^(1[6-9]|[2-9][0-9]|100)$/
                  }
                  inputMethodHints: Qt.ImhDigitsOnly
                }

                Label {
                    Layout.alignment: Qt.AlignLeft
                    text: qsTr("A")
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 0
                visible: selectionTabs.currentIndex === 0
                spacing: 0

                Label {
                    id: nominalCurrentError
                    Layout.topMargin: 0
                    text: qsTr("Please input a value between 10 and 100.")
                    color: "#AA0A24"
                    font.pixelSize: 13
                    visible: false
                }
            }

            RowLayout {
                Layout.topMargin: 20
                Layout.bottomMargin: 0
                visible: selectionTabs.currentIndex === 1
                spacing: 0
                TextField {
                  id: power
                  Layout.preferredWidth: 70
                  Layout.rightMargin: 20
                  placeholderText: qsTr("2.3 - 100")
                  onTextChanged: {
                      phaseLimit = parseInt(power.text)
                  }
                  validator: RegExpValidator {
                      regExp: /^(2[.,][3-9]\d*|[3-9]([.,]\d+)?|[1-9]\d([.,]\d+)?|100([.,]0+)?)$/
                  }
                  inputMethodHints: Qt.ImhDigitsOnly
                }

                Label {
                    Layout.alignment: Qt.AlignLeft
                    text: qsTr("kW")
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 0
                visible: selectionTabs.currentIndex === 1
                spacing: 0
                Label {
                    id: powerError
                    Layout.topMargin: 0
                    text: qsTr("Please input a value between 2.3 and 100.")
                    color: "#AA0A24"
                    font.pixelSize: 13
                    visible: false
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: savebutton

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: 150
            Layout.bottomMargin: 160
            text: qsTr("Save")
            onClicked: {

                if(power.text <= 2.2){
                    powerError.visible = true
                }else if(nominalCurrent.text <= 15 && power.text <= 2.2){
                    nominalCurrentError.visible = true
                }
                /*
                //hemsManager.setBatteryConfiguration(batteryConfiguration.batteryThingId, { controllableLocalSystem: gridSupportControl.checked, avoidZeroFeedInEnabled: zeroCompensationControl.checked})
                if(directionID !== 1){
                    pageStack.pop()
                }
                root.done()*/
            }
        }

    }

}
