import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material 2.12
import QtQuick.Controls
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    id: interfaceItem
    anchors.fill: parent


    property var infotext: false
    property var summaryText: false
    property alias body: bodyContainer.children
    property var infofooter: false
    signal furtherReading(var link)
    ScrollView{
        clip: true
        id: infoscroller
        anchors.top: parent.top
        width: parent.width
        height: parent.height
    ColumnLayout{
        id: upperColumn
        anchors.top: parent.top

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
        // default explanation. Only used if the body is not implemented
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
            clip: true
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            height: childrenRect.height
            visible: body !== null ? true : false
            Layout.bottomMargin: 15

        }



        Item{
            id: footerContainer
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            Layout.leftMargin: app.margins +10
            Layout.rightMargin: app.margins +10
            visible: infofooter ? true: false

            ColumnLayout{
                id: footerLayout
                Layout.fillWidth: true
                Label{
                    id: furtherReading
                    Layout.fillWidth: true
                    text: qsTr("Further Readings:")
                    font.bold: true
                    font.pixelSize: 17
                }
                Repeater{
                    id: footerRepeater
                    model: infofooter
                    Layout.fillWidth: true
                    delegate: ItemDelegate{
                        Layout.fillWidth: true
                        RowLayout{
                            Layout.fillWidth: true
                            ConsolinnoItemDelegate{
                                Layout.minimumWidth: app.width - 3*app.margins
                                text: modelData.headline
                                id: infoLink

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
    }



}
