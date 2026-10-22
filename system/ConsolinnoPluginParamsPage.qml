import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../delegates"

SettingsPageBase {
    id: root
    property var plugin: null

    headerText: plugin ? plugin.name : ""

    property Component navbarControls: Component {
        CoNavbarButton {
            text: qsTr("Apply changes")
            enabled: paramRepeater.dirty
            onClicked: pluginConfigManager.savePluginConfig()
        }
    }

    Connections {
        target: engine.thingManager
        function onSavePluginConfigReply(commandId, thingError) {
            if (thingError === Thing.ThingErrorNoError) {
                pageStack.pop();
            } else {
                console.warn("Error saving plugin params:", thingError)
                var dialog = errorDialog.createObject(root, {error: thingError});
                dialog.open();
            }
        }
    }

    PluginConfigManager {
        id: pluginConfigManager
        engine: _engine
        plugin: root.plugin
    }

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: paramsGroup
            Layout.fillWidth: true
            headerText: qsTr("Settings")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                Repeater {
                    id: paramRepeater
                    model: pluginConfigManager.params

                    property bool dirty: false
                    function checkDirty() {
                        for (var i = 0; i < paramRepeater.count; i++) {
                            if (paramRepeater.itemAt(i).dirty) {
                                dirty = true;
                                return;
                            }
                        }
                        dirty = false;
                    }

                    delegate: CoParamDelegate {
                        Layout.fillWidth: true
                        paramType: root.plugin.paramTypes.getParamType(model.id)
                        value: pluginConfigManager.params.getParam(model.id).value
                        param: pluginConfigManager.params.getParam(model.id)
                        onDirtyChanged: paramRepeater.checkDirty()
                    }
                }
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }
}
