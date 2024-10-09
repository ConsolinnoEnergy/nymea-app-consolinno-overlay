import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("App Settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight
        clip: true

        GridLayout {
            id: layout
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: 0
            columnSpacing: 0

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Look & feel")
                subText: qsTr("Customize the app's look and behavior")
                iconSource: "../images/preferences-look-and-feel.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("ConsolinnoLookAndFeelSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Developer options")
                subText: qsTr("Access tools for debugging and error reporting")
                iconSource: "../images/sdk.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("DeveloperOptionsPage.qml"))
            }
            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("About %1").arg(Configuration.appName)
                subText: qsTr("Find app versions and licence information")
                iconSource: "../images/info.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
