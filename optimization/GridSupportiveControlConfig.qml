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
    property int directionID: 0

    signal done(bool skip, bool abort, bool back)

    header: NymeaHeader {
        text: qsTr("Grid Supportive Control")
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


    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }
    /*
        Button {
            id: savebutton
            Layout.fillWidth: true
            text: qsTr("Save")

            onClicked: {

            }

        }
    */
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Component.onCompleted: {

        }
    }

}
