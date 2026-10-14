import QtQuick
import QtQuick.Controls
import QtQml
import Nymea
import QtQuick.Layouts


import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property var stack

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Capacity")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true

    }

    InfoTextInterface{
        navigationFooterHeight: root.navigationFooterHeight
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("Please enter the battery capacity of your vehicle. You will find this in your vehicle registration document.")
            }
        }
    }
}
