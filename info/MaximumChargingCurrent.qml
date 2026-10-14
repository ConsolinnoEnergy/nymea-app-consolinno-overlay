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
        show_Image: true
        text: qsTr("Maximum Charging Current")
        backButtonVisible: true
        onBackPressed: stack.pop()
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
                text: qsTr("Enter the maximum charging current supported by your vehicle. This setting is used to account for the vehicle’s available charging power in calculations.")
            }
        }
    }
}
