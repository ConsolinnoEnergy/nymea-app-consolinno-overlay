import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import QtGraphicalEffects 1.15
import QtQuick.Controls.Material 2.12
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    property var push
    property var stack
    implicitWidth: 18
    implicitHeight: 18

    InfoModal {
        id: infoModal
        parent: Overlay.overlay
    }

    Image{
        id: infoImage
        anchors.fill: parent
        source: "/icons/info.svg"
        MouseArea{
            anchors.fill: parent
            onClicked:{
                if (push)
                {
                    // Extract title from filename (remove .qml and add spaces)
                    var titleText = push.replace(".qml", "").replace(/([A-Z])/g, " $1").trim()
                    if (titleText === "CloudServicesActivateInfo") {
                        titleText = qsTr("Activate Cloud Services")
                    } else if (titleText === "EnergyMonitoringInfo") {
                        titleText = qsTr("Energy Monitoring")
                    } else if (titleText === "AnonymizedUsageDataInfo") {
                        titleText = qsTr("Anonymized Usage Data")
                    }
                    infoModal.title = titleText

                    // Load the content component
                    var component = Qt.createComponent("../info/" + push)
                    if (component.status === Component.Ready) {
                        var content = component.createObject(infoModal, {})
                        infoModal.contentItem = content
                        if (content && content.closeRequested) {
                            content.closeRequested.connect(infoModal.close)
                        }
                        infoModal.open()
                    } else {
                        console.warn("Failed to load info component:", push, component.errorString())
                    }
                }
            }
        }
    }
    ColorOverlay{
        anchors.fill: infoImage
        source: infoImage
        color: Material.foreground
    }

}

