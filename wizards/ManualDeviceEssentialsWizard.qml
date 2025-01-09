import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Essential Optimizations Settings")
        backButtonVisible: true
        onBackPressed:{
            pageStack.pop()
        }
    }

    property HemsManager hemsManager

    Item {
        id: screenWrapper

        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)

        Item {
            id: essentialsText

            anchors.fill: parent

            Label {
                id: essentialText

                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Style.majorFontSize
                text: qsTr("If a heat pump or an inverter is added, the settings for optimization must be entered.\n\n After adding a heat pump or a wallbox, the blackout protection must be adjusted accordingly.\n")
            }

            MouseArea {
                width: parent.width
                height: screenGuideText.height
                anchors {
                    top: essentialText.bottom
                }

                Label {
                    width: parent.width
                    id: screenGuideText
                    wrapMode: Text.WordWrap
                    text: qsTr("(The settings can be found in the wrench menu under <font color=\"%1\"> Optimization Settings </font>).").arg(Style.consolinnoMedium)
                }

                onClicked: pageStack.push(Qt.resolvedUrl("../mainviews/OptimizationConfiguration.qml"), { hemsManager: hemsManager })
            }


            Button {
                text: qsTr("Next")
                /*background: Rectangle{
                    color:  Style.
                    radius: 4
                }*/
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                width: parent.width / 2

                topPadding: Style.buttonTopPadding
                bottomPadding: Style.buttonTopPadding
                leftPadding: Style.buttonLeftPadding
                rightPadding: Style.buttonLeftPadding
                font.pixelSize: Style.buttonFontSize

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../thingconfiguration/AddNewThings.qml"))
                }
            }
        }
    }
}
