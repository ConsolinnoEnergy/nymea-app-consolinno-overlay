import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "../components"

Item {
    id: root
    property alias text: radioButton.text
    property alias checked: radioButton.checked
    property alias iconRight: rightButton.icon

    signal rightButtonClicked()
    signal radioButtonClicked()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.rightMargin: Style.smallMargins
        spacing: Style.smallMargins

        RadioButton {
            id: radioButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            autoExclusive: false

            onClicked: {
                root.radioButtonClicked();
            }
        }

        Rectangle {
            id: divider
            Layout.fillHeight: true
            Layout.topMargin: Style.smallMargins
            Layout.bottomMargin: Style.smallMargins
            width: 2
            color: Style.colors.typography_Basic_Divider
        }

        CoIconButton {
            id: rightButton
            Layout.alignment: Qt.AlignCenter
            onClicked: root.rightButtonClicked()
        }
    }
}
