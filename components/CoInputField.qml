import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias text: textinput.text
    property alias acceptableInput: textinput.acceptableInput
    property alias textField: textinput
    property alias labelText: label.text
    property alias infoUrl: label.push
    property alias helpText: helpLabel.text
    property alias unit: unitLabel.text
    property alias feedbackText: notification.text
    property alias showLabel: labelLayout.visible
    property bool compact: false

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    ColumnLayout{
        id: layout
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: 0

        ColumnLayout {
            id: labelLayout
            Layout.fillWidth: true
            spacing: Style.smallMargins
            opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity

            LabelWithInfo {
                id: label
                Layout.fillWidth: true
            }

            Text {
                id: helpLabel
                Layout.fillWidth: true
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
                text: ""
                visible: text !== ""
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.smallMargins

            TextField {
                id: textinput
                Layout.fillWidth: true
                Layout.preferredWidth: root.compact ? 0 : -1
                Layout.leftMargin: -4
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            Text {
                id: unitLabel
                Layout.fillWidth: root.compact
                Layout.preferredWidth: root.compact ? 0 : -1
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                text: ""
                visible: root.compact ? true : text !== ""
                opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity
            }
        }

        CoFieldNotification {
            id: notification
            Layout.fillWidth: true
            text: ""
            visible: root.enabled && text !== "" && !textinput.acceptableInput
        }
    }
}
