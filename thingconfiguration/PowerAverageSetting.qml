import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../optimization"

Page {
    id: root


    property UserConfiguration userconfig



    header: ConsolinnoHeader {
        id: header
        text: qsTr("Power Averaging")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Style.margins
            leftMargin: Style.margins
            rightMargin: Style.margins
        }


        SwitchDelegate {
            id: averagingPowerEnabledSwitch
            Layout.fillWidth: true
            text: qsTr("Averaging power enabled (considers the last 10 values)")
            checked: userconfig.averagingPowerEnabled
            onToggled: userconfig.averagingPowerEnabled = checked
        }



    }
}
