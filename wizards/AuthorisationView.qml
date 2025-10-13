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
    property HemsManager hemsManager

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
            text: qsTr("To comission devices with the %1, you must be authorized. Otherwise the warranty expires.").arg(Configuration.coreBranding)
        }

        ConsolinnoCheckbox {
            id: authorisationCheckbox
            Layout.fillWidth: true
            position: Qt.AlignHCenter
            text: qsTr("I am authorized to operate the %1").arg(Configuration.coreBranding)
        }


        ColumnLayout {
            spacing: Style.margins
            Layout.alignment: Qt.AlignHCenter

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("cancel")
                Layout.preferredWidth: 200
                onClicked: {
                    pageStack.pop()
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("next")
                enabled: authorisationCheckbox.checked
                Layout.preferredWidth: 200
                onClicked: {
                    if (authorisationCheckbox.checked) {
                        if (directionID == 0){
                            root.done(false, true)
                        }else if(directionID == 1){
                            pageStack.replace(Qt.resolvedUrl("../thingconfiguration/AddNewThings.qml"), { hemsManager: hemsManager })
                        }

                    }
                }
            }

        }

    }

}
