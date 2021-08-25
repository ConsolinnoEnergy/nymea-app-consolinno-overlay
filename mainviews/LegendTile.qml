import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../delegates"

Rectangle {
    id: legendDelegate
    height: childrenRect.height
    width: 100
    radius: Style.cornerRadius

    property Thing thing: null
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null

    ColumnLayout {
        width: parent.width

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: headerLabel.height + Style.margins
            color: Qt.darker(legendDelegate.color, 1.3)

            Label {
                id: headerLabel
                width: parent.width
                text: legendDelegate.thing.name
                elide: Text.ElideRight
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            text: legendDelegate.currentPowerState.value.toFixed(0) + " W"
            horizontalAlignment: Text.AlignHCenter
            font: Style.bigFont
            color: "white"
        }
    }
}
