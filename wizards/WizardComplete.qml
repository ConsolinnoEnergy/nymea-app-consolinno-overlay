import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root
    headerBackgroundColor: "white"


    showNextButton: false
    showBackButton: false

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: Style.margins
        spacing: Style.hugeMargins
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "/ui/images/intro-bg-graphic.svg"
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, 300)
            spacing: Style.margins

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font: Style.bigFont
                text: qsTr("Congratulations!")
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Your Leaflet is now configured. The following devices have been set up:")
            }

            ColumnLayout {
                Repeater {
                    model: engine.thingManager.things
                    delegate: Label {
                        Layout.fillWidth: true
                        text: model.name
                        horizontalAlignment: Text.AlignHCenter
                        color: Style.accentColor
                    }
                }
            }

            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Configure optimizations")
                color: Style.accentColor
                onClicked: root.done(false, false)
                enabled: false
            }
            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("skip")
                color: Style.blue
                onClicked: root.done(true, false)
            }
        }
    }
}
