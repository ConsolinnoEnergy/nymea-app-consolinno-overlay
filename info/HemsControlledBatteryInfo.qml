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
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("HEMS-controlled battery")
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
                text: qsTr("When the \"HEMS-controlled battery\" toggle is activated, the HEMS controls the charging and discharging of the battery up to the defined minimum and maximum state of charge (SoC).")
            }
        }
    }
}
