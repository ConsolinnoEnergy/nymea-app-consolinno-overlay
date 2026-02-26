import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea 1.0
import "../components"
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

    // Houshold phase limit [A]
    ColumnLayout {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        //anchors.margins: app.margins


        RadioDelegate {
            id: limit25
            Layout.fillWidth: true
            text: qsTr("Per phase: 25 A")
            onClicked: phaseLimit = 25
        }
        RadioDelegate {
            id: limit35
            Layout.fillWidth: true
            text: qsTr("Per phase: 35 A")
            onClicked: phaseLimit = 35
        }
        RadioDelegate {
            id: limit40
            Layout.fillWidth: true
            text: qsTr("Per phase: 40 A")
            onClicked: phaseLimit = 40
        }
        RadioDelegate {
            id: limit50
            Layout.fillWidth: true
            text: qsTr("Per phase: 50 A")
            onClicked: phaseLimit = 50
        }
        RadioDelegate {
            id: limit63
            Layout.fillWidth: true
            text: qsTr("Per phase: 63 A")
            onClicked: phaseLimit = 63
        }
        RadioDelegate {
            id: limitOther
            Layout.fillWidth: true
            text: "other"

            contentItem: RowLayout {
              Label {
                text: qsTr("Per phase A:")
                Layout.rightMargin: 40
              }
              ConsolinnoTextField {
                id: otherLimit
                rightPadding: 50
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
              Item {
                  Layout.fillWidth: true

              }
            }
            onClicked: phaseLimit = otherLimit.text
        }


        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            color: Style.dangerAccent
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont

        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
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

}
