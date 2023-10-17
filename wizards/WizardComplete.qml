import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

//    headerBackgroundColor: "white"
    headerLabel: qsTr("Installed Devices")
    background: Item {}

    property HemsManager hemsManager: null

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
                text: qsTr("Your Leaflet is now configured. The following devices have been set up:")
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

            //            ConsolinnoButton {
            //                Layout.alignment: Qt.AlignHCenter
            //                text: qsTr("Configure optimizations")
            //                color: Style.accentColor
            //                onClicked: {
            //                    var page = pageStack.push(Qt.resolvedUrl("ConfigureOptimizationsWizard.qml"), {hemsManager: hemsManager})
            //                    page.done.connect(function(skip, abort) {
            //                        root.done(skip, abort)
            //                    })
            //                }
            //            }
            //            ConsolinnoButton {
            //                Layout.alignment: Qt.AlignHCenter
            //                text: qsTr("skip")
            //                color: Style.blue
            //                onClicked: root.done(true, false)
            //            }
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
