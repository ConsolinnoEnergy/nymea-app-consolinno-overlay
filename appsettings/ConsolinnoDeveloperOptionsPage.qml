import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("Developer options")

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: loggingGroup
            Layout.fillWidth: true
            headerText: qsTr("Logging")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoSwitch {
                    id: appLogSwitch
                    Layout.fillWidth: true
                    text: qsTr("Application logs enabled")
                    checked: AppLogController.enabled
                    onCheckedChanged: AppLogController.enabled = checked
                }

                CoCard {
                    id: liveLogCard
                    Layout.fillWidth: true
                    text: qsTr("View live log")
                    visible: AppLogController.enabled
                    interactive: true
                    showChildrenIndicator: true
                    onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/AppLogPage.qml"))
                }

                CoCard {
                    id: logCategoriesCard
                    Layout.fillWidth: true
                    text: qsTr("Configure logging categories")
                    interactive: true
                    showChildrenIndicator: true
                    onClicked: pageStack.push(Qt.resolvedUrl("../appsettings/LoggingCategories.qml"))
                }
            }
        }
    }
}
