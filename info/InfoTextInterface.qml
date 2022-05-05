import QtQuick 2.12
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Item {
    property var infotext
    ColumnLayout{
        Text {
            id: textLabel
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.1
            color: "darkgreen"
            text: infotext
            leftPadding: app.margins +10
            rightPadding: app.margins +10
            topPadding: app.height/3
        }
    }
}
