import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0


ConsolinnoWizardPageBase {
    id: root

    showBackButton: false
    showNextButton: false

    property real directionID: 0

    content: ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        spacing: Style.margins

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font: Style.bigFont
            wrapMode: Text.WordWrap
            text: qsTr("Authorisation page")

        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("To comission devices with the Leaflet, you must be authorized. Otherwise the warranty expires.")
        }


        CheckBox{
        id: authorisationCheckbox
        Layout.alignment: Qt.AlignCenter
        text: qsTr("I am authorized to operate the Leaflet")
        }


        ColumnLayout {
            spacing: Style.margins
            Layout.alignment: Qt.AlignHCenter

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("cancel")
                background: Rectangle{
                    color: "#87BD26"
                    radius: 4
                }
                Layout.preferredWidth: 200
                onClicked: {
                    pageStack.pop()
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("next")
                background: Rectangle{
                    color: authorisationCheckbox.checked  ? "#87BD26" : "grey"
                    radius: 4
                }
                Layout.preferredWidth: 200
                onClicked: {
                    if (authorisationCheckbox.checked) {
                        if (directionID == 0){
                            root.done(false, true)
                        }else if(directionID == 1){

                            pageStack.replace(Qt.resolvedUrl("../thingconfiguration/NewThingPage.qml"))
                        }

                    }
                }
            }









        }

    }

}
