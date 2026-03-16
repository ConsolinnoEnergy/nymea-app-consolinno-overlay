import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2

import "../components"
import "../delegates"

ColumnLayout {
    id: root

    signal closeRequested()

    spacing: 0

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("What does this setting mean?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        wrapMode: Text.WordWrap
        text: qsTr("This setting enables exclusively the connection to the system's authorized cloud services. Through these, functions such as data synchronization, secure remote access, and system updates are provided. The system only connects to the manufacturer's explicitly designated services – not to external or arbitrary cloud providers.")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 16
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("Which data is transmitted?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        wrapMode: Text.WordWrap
        text: qsTr("The connection enables basic communication between the system and the Consolinno servers. Which data categories are specifically shared is determined by the individual release settings below. No additional data is transmitted without your explicit consent.")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 16
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("Can I deactivate the connection at any time?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 8
        wrapMode: Text.WordWrap
        text: qsTr("Yes. You can deactivate the cloud connection at any time. The system will then continue to operate entirely in local mode. Some functions that require an active cloud connection will not be available in this case.")
    }
}
