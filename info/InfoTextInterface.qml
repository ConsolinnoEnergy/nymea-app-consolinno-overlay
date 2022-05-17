import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.12
import QtQuick.Controls 2.15
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    id: root
    property var infotext: false
    property var summaryText: false
    property alias body: bodyContainer.children
    property var footer: false
    signal furtherReading(var link)
    ColumnLayout{
        Label{
            id: summaryHeadline
            text: qsTr("Summary:")
            font.bold:  true
            font.pixelSize: 17
            visible: summaryText ? true : false
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Material.foreground: Material.foreground
            Layout.topMargin: 10
            leftPadding: app.margins +10
            rightPadding: app.margins +10
        }

        Label{
            id: summary
            text: summaryText
            visible: summaryText ? true : false
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Material.foreground: Material.foreground
            leftPadding: app.margins +10
            rightPadding: app.margins +10
            Layout.bottomMargin: 15
            wrapMode: Text.WordWrap

            }
        // default explanaition. Only used if the body is not implemented
        Label {
            id: textLabel
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            lineHeight: 1.1
            Material.foreground: Material.foreground
            text: infotext
            leftPadding: app.margins +10
            rightPadding: app.margins +10
            topPadding: app.height/3
            visible: infotext && body !== null ? true: false

        }
        Item {
            id: bodyContainer
            Layout.fillWidth: true
            height: childrenRect.height
            visible: body !== null ? true : false


        }

        Item{
            id: footerContainer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins +10
            Layout.rightMargin: app.margins +10
            Layout.topMargin: 15
            visible: footer ? true: false
            ColumnLayout{
                Layout.fillWidth: true
                Label{
                    Layout.fillWidth: true
                    id: furtherReading
                    text: qsTr("Further Readings:")
                    font.bold: true
                    font.pixelSize: 17
                }
                Repeater{
                    id: footerRepeater
                    model: footer
                    delegate: ItemDelegate{
                        NymeaItemDelegate{
                            text: modelData.headline
                            id: infoLink
                            Layout.fillWidth: true
                            onClicked:
                            {
                                stack.replace(Qt.resolvedUrl("../info/" + modelData.Link + ".qml"), {stack: stack} )



                            }

                        }
                    }


                }
            }
        }


    }
}
