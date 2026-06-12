import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property var stack
    property bool hasBattery: false
    property double batteryTargetSoc: 0

    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("PV device priorization")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface {
        navigationFooterHeight: root.navigationFooterHeight
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The listed devices can use PV surplus. Arrange them by drag & drop according to their priority.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("An SG Ready heat pump without a meter always takes priority over all other devices when controlled via Leaflet HEMS and cannot be moved.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                visible: root.hasBattery
                text: qsTr("The battery is always prioritized last once the SoC reaches %1%, regardless of its position in the list.").arg(root.batteryTargetSoc)
            }
        }
    }
}
