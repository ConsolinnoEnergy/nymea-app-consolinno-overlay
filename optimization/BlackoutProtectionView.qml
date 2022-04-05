import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property HemsManager hemsManager

    header: NymeaHeader {
        text: qsTr("Blackout protection")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
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
            id: limit50
            Layout.fillWidth: true
            text: "3 x 50 A"
            onClicked: phaseLimit = 50
        }
        RadioDelegate {
            id: limit65
            Layout.fillWidth: true
            text: "3 x 65 A"
            onClicked: phaseLimit = 65
        }
        RadioDelegate {
            id: limitOther
            Layout.fillWidth: true
            text: "other"
            contentItem: TextField {
                id: otherLimit
                rightPadding: 50//otherDelegate.width - otherDelegate.indicator.width - otherDelegate.spacing
                onTextChanged: {
                    limitOther.checked = true
                    phaseLimit = parseInt(text)
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
            text: qsTr("Save")

            onClicked: {
                // TODO: wait for response
                // for debugging purposes or to let the user know that some values are not valid
                //footer.text = "clicked"
                d.pendingCallId = hemsManager.setHousholdPhaseLimit(root.phaseLimit)
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
            case 50:
                limit50.checked = true
                break
            case 65:
                limit65.checked = true
                break
            default:
                limitOther.checked = true
                otherLimit.text = configuredPhaseLimit
                break
            }
        }





    }

}
