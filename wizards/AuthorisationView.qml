import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "qrc:/ui/components"
import Nymea 1.0


Page {
    id: root

    signal done(bool skip, bool abort)

    property real directionID: 0

    header: NymeaHeader {
        text: qsTr("Authorisation page")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
            useFillWidth: false
            position: Qt.AlignHCenter
            text: qsTr("I am authorized to operate the %1").arg(Configuration.coreBranding)
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Next")
            enabled: authorisationCheckbox.checked
            onClicked: {
                if (authorisationCheckbox.checked) {
                    if (directionID == 0) {
                        root.done(false, true);
                    } else if (directionID == 1) {
                        pageStack.replace(Qt.resolvedUrl("../thingconfiguration/AddNewThings.qml"));
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Cancel")
            secondary: true
            onClicked: {
                pageStack.pop();
            }
        }
    }
}
