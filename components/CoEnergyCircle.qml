import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.impl 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0
import NymeaApp.Utils 1.0


Item {
    id: root
    property alias icon: icon.name
    property alias label: labelText.text
    property double power: 0
    property color circleColor: "transparent"
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
                anchors.fill: parent
                visible: !root.idle
                horizontalRadius: parent.width - 2 * parent.padding
                verticalRadius: parent.height - 2 * parent.padding
                gradient: Gradient {
//                    property double gradientWidth: 0.01 + 0.09 * (Math.min(Math.abs(root.power), 5000) / 5000)
                    GradientStop{ position: 0.5; color: "transparent" }
                    GradientStop{ position: 0.5001; color: background.gradientColor }
                    GradientStop{ position: 0.53 + 0.07 * (Math.min(Math.abs(root.power), 5000) / 5000); color: "transparent" }
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
                anchors.fill: parent
                visible: !root.idle
                gradient: Gradient {
//                    property double gradientWidth: 0.01 + 0.19 * (Math.min(Math.abs(root.power), 5000) / 5000)
                    GradientStop{ position: 0.5; color: "transparent" }
                    GradientStop{ position: 0.4999; color: background.gradientColor }
                    GradientStop{ position: 0.47 - 0.17 * (Math.min(Math.abs(root.power), 5000) / 5000); color: Style.colors.typography_Background_Default }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
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
                    maximumLineCount: 1
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
                        text: NymeaUtils.floatToLocaleString(root.power, 0)
                        font: Style.newH2Font
                        color: Style.colors.components_Dashboard_Info_card_value
                    }

                    Text {
                        id: unitText
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("W") // #TODO show large values as "kW"?
                        font: Style.newParagraphFontBold
                        color: Style.colors.components_Dashboard_Info_card_value
                    }
                }
            }
        }
    }
}
