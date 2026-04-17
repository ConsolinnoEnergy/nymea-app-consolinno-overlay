import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property Thing thing: null

    title: root.thing.name
    headerOptionsModel: detailMenuModel

    ListModel {
        id: detailMenuModel

        ListElement {
            icon: "/icons/logs.svg"
            text: "Logs"
            page: "../devicepages/DeviceLogPage.qml"
        }
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight
                           + columnLayout.anchors.topMargin
                           + columnLayout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                // TODO: Add detail value components here
            }
        }
    ]
}
