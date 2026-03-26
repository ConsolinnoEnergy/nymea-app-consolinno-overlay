import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias value: slider.value
    property alias from: slider.from
    property alias to: slider.to
    property alias labelText: label.text
    property alias infoUrl: label.push
    property alias valueText: valueLabel.text
    property alias helpText: helpLabel.text
    property alias feedbackText: notification.text
    property alias showLabel: labelLayout.visible

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    ColumnLayout{
        id: layout
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: 0

        RowLayout {
            id: labelLayout
            Layout.fillWidth: true
            spacing: Style.smallMargins
            opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity

            ColumnLayout {
                Layout.fillWidth: true

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

            Text {
                id: valueLabel
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
        }

        CoFieldNotification {
            id: notification
            Layout.fillWidth: true
            text: ""
            visible: root.enabled && text !== ""
        }
    }
}
