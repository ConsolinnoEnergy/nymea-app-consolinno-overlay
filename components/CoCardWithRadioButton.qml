import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias text: card.text
    property alias helpText: card.helpText
    property alias labelText: card.labelText
    property alias showChildrenIndicator: card.showChildrenIndicator
    property alias iconLeft: card.iconLeft
    property alias iconRight: card.iconRight
    property alias checked: radioButton.checked

    signal clicked()
    signal radioButtonClicked()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        spacing: Style.margins

        RadioButton {
            id: radioButton
            autoExclusive: false

            onClicked: {
                root.radioButtonClicked();
            }
        }

        Rectangle {
            id: divider
            Layout.fillHeight: true
            width: 2
            color: Style.colors.typography_Basic_Divider
        }

        CoCard {
            id: card
            Layout.fillWidth: true
            interactive: true

            onClicked: {
                root.clicked();
            }
        }
    }
}
