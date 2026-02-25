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
        text: qsTr("Zero Compensation")
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
                text: qsTr("On days with negative electricity prices, battery capacity is actively reserved to allow charging during these periods and to avoid feeding electricity into the grid without compensation. As soon as the control system is active, charging from the grid is disabled (as indicated by the greyed-out controls).")
            }
        }
    }
}

