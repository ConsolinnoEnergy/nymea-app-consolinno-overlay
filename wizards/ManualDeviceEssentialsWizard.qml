import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

Page {
    id: root
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    anchors { left: parent.left; right: parent.right; }

    header: NymeaHeader {
        text: qsTr("Essential Optimizations Settings")
        backButtonVisible: true
        onBackPressed:{
            pageStack.pop()
        }
    }

    property HemsManager hemsManager
    ColumnLayout {
        id: screenWrapper
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        property int labelMargins: 10

        anchors { left: parent.left; right: parent.right; }
        spacing: Style.margins

        Label {
            id: essentialText

            Layout.topMargin: 50
            Layout.leftMargin: screenWrapper.labelMargins
            Layout.rightMargin: screenWrapper.labelMargins
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
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

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0


            Button {
                text: qsTr("Next")

                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Style.buttonFontSize

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../thingconfiguration/AddNewThings.qml"))
                }
            }
        }
    }
}
