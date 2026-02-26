import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Activate instant charging")
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
                text: qsTr("When the function is activated, the battery is charged once with the maximum charging current from the grid – regardless of the PV surplus or the current electricity price. During the charging process, no discharging takes place.")
            }

        }
    }
}

