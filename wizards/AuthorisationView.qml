import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0


ConsolinnoWizardPageBase {
    id: root

    showBackButton: false
    showNextButton: false

    //onNext: pageStack.push(searchEnergyMeterComponent, {thingClassId: thingClassComboBox.currentValue})

    content: ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        spacing: Style.margins

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font: Style.bigFont
            wrapMode: Text.WordWrap
            text: qsTr("Authorisation Page")
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("To operate devices with the Leaflet, you must be authorized. Otherwise the warranty will be void")
        }


        CheckBox{
        id: authorisationCheckbox
        Layout.alignment: Qt.AlignCenter
        text: qsTr("I am authorized to operate the Leaflet")
        }


        ColumnLayout {
            spacing: Style.margins
            Layout.alignment: Qt.AlignHCenter

            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: authorisationCheckbox.checked ? qsTr("next") : qsTr("cancel")
                color: authorisationCheckbox.checked ? Style.accentColor : Style.yellow

                onClicked: {
                    if (authorisationCheckbox.checked) {
                        root.done(false, true)
                    } else {
                        Qt.quit()
                    }
                }
            }

        }

    }

}
