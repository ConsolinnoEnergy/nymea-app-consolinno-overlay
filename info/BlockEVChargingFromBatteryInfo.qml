import QtQuick
import QtQuick.Controls
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Block charging")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("Charging the electric car from the battery is blocked.")
            }

        }
    }
}

