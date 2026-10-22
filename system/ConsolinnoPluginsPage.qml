import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("Plugins")

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: pluginsGroup
            Layout.fillWidth: true
            headerText: qsTr("Installed integration plugins")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                Repeater {
                    model: PluginsProxy {
                        id: pluginsProxy
                        plugins: engine.thingManager.plugins
                    }

                    delegate: CoCard {
                        Layout.fillWidth: true
                        property Plugin plugin: pluginsProxy.get(index)
                        iconLeft: "qrc:/icons/plugin.svg"
                        text: model.name
                        interactive: plugin.paramTypes.count > 0
                        showChildrenIndicator: interactive
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ConsolinnoPluginParamsPage.qml"), { plugin: plugin })
                        }
                    }
                }
            }
        }
    }
}
