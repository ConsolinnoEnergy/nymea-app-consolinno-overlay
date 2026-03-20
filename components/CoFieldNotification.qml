import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

Item {
    property alias text: label.text

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Style.smallMargins

        ColorIcon {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.topMargin: 2
            size: 17
            color: Style.colors.system_Danger_Accent
            name: Qt.resolvedUrl("/icons/warning.svg")
        }

        Text {
            id: label
            Layout.fillWidth: true
            font: Style.newParagraphFont
            color: Style.colors.system_Danger_Accent
            wrapMode: Text.WordWrap
        }
    }
}
