import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl
import Qt5Compat.GraphicalEffects
import Nymea 1.0
import NymeaApp.Utils 1.0


Item {
    id: root
    property alias icon: icon.name
    property alias label: labelText.text
    property double power: 0
    property color circleColor: Style.colors.components_Dashboard_Detail_Energy_circle_border
    property bool idle: Math.round(power) === 0

    implicitHeight: background.implicitHeight
    implicitWidth: background.implicitWidth

    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"

        implicitHeight: 350
        implicitWidth: 350

        property color gradientColor: Qt.rgba(root.circleColor.r,
                                              root.circleColor.g,
                                              root.circleColor.b,
                                              0.4)

        PaddedRectangle {
            id: outerCircle
            anchors.centerIn: parent
            padding: 32
            height: Math.min(parent.height, parent.width)
            width: height
            radius: height / 2
            color: root.idle ?
                       Style.colors.components_Dashboard_Detail_Energy_circle_empty :
                       Style.colors.components_Dashboard_Detail_Energy_circle
            border.width: root.idle ? 0 : 1
            border.color: Style.colors.components_Dashboard_Detail_Energy_circle_border

            RadialGradient {
                id: outerGradient
                anchors.fill: parent
                visible: !root.idle
                horizontalRadius: parent.width - 2 * parent.padding
                verticalRadius: parent.height - 2 * parent.padding
                property real offset: 0.53
                property real extent: 0.1
                gradient: Gradient {
                    GradientStop{ position: 0.5; color: "transparent" }
                    GradientStop{ position: 0.5001; color: background.gradientColor }
                    GradientStop{
                        position: outerGradient.offset + outerGradient.extent * (Math.min(Math.abs(root.power), 5000) / 5000)
                        color: "transparent"
                    }
                }
            }
        }

        Rectangle {
            id: innerCircle
            property double circleWidth: 20 + 12 * (Math.min(Math.abs(root.power), 5000) / 5000)
            anchors.centerIn: parent
            anchors.margins: outerCircle.padding + circleWidth
            height: Math.min(parent.height - 2 * anchors.margins, parent.width - 2 * anchors.margins)
            width: height
            radius: height / 2
            color: Style.colors.typography_Background_Default
            border.width: root.idle ? 0 : 1
            border.color: Style.colors.components_Dashboard_Detail_Energy_circle_border

            RadialGradient {
                id: innerGradient
                anchors.fill: parent
                visible: !root.idle
                property real offset: 0.46
                property real extent: 0.14
                gradient: Gradient {
                    GradientStop{ position: 0.5; color: "transparent" }
                    GradientStop{ position: 0.4999; color: background.gradientColor }
                    GradientStop{
                        position: innerGradient.offset - innerGradient.extent * (Math.min(Math.abs(root.power), 5000) / 5000)
                        color: Style.colors.typography_Background_Default
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 50
                spacing: 0

                ColorIcon {
                    id: icon
                    Layout.alignment: Qt.AlignCenter
                    Layout.bottomMargin: 3
                    size: 24
                    color: Style.colors.brand_Basic_Icon_accent
                }

                Text {
                    id: labelText
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font: Style.newParagraphFontBold
                    color: Style.colors.components_Dashboard_Info_card_title
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    spacing: 3

                    Text {
                        id: valueText
                        verticalAlignment: Text.AlignVCenter
                        text: UiUtils.powerDisplayValue(root.power)
                        font: Style.newH2Font
                        color: Style.colors.components_Dashboard_Info_card_value
                    }

                    Text {
                        id: unitText
                        verticalAlignment: Text.AlignVCenter
                        text: UiUtils.powerDisplayUnit(root.power)
                        font: Style.newParagraphFontBold
                        color: Style.colors.components_Dashboard_Info_card_value
                    }
                }
            }
        }
    }
}
