import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    headerLabel: qsTr("Installed Devices")

    showNextButton: false
    showBackButton: false

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: Style.margins
        spacing: Style.hugeMargins

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: Configuration.isIntroIcon !== true
        }

        Image {
            id: introIcon
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "/ui/images/intro-bg-graphic.svg"
            fillMode: Image.PreserveAspectFit
            visible: Configuration.isIntroIcon
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 300)
            spacing: Style.margins

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font: Style.bigFont
                text: qsTr("Congratulations!")
            }
            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Your %1 is now configured. The following devices are set up:").arg(Configuration.deviceName)
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 50
                model: engine.thingManager.things
                clip: true
                delegate: Label {
                    width: parent.width
                    text: model.name
                    horizontalAlignment: Text.AlignHCenter
                    color: Style.accentColor
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("to the Dashboard")
                Layout.preferredWidth: 200
                //color: Style.blue
                onClicked: root.done(true, false)
            }



        }
    }
}
