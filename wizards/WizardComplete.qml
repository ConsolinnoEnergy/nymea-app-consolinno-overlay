import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root
    headerBackgroundColor: "white"

    nextButtonText: qsTr("Get started")
    showBackButton: false

    background: Rectangle {
        color: "#D9D9D8"
    }

    onNext: done()

    content: ColumnLayout {
        anchors.fill: parent
        Label {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            font: Style.bigFont
            text: qsTr("Done!")
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            text: qsTr("The setup is completed!")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            text: qsTr("You may add more devices at any time in the thing configuration.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "/ui/images/wizard-done.png"
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignVCenter
            horizontalAlignment: Image.AlignHCenter
        }
    }
}
