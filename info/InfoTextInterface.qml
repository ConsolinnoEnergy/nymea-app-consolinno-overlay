import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.12
import QtQuick.Controls 2.15
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    id: interfaceItem
    anchors.fill: parent


    property var infotext: false
    property var summaryText: false
    property alias body: bodyContainer.children
    property var infofooter: false
    ScrollView{
        clip: true
        id: infoscroller
        anchors.top: parent.top
        width: parent.width
        height: parent.height
    ColumnLayout{
        id: upperColumn
        anchors.top: parent.top

        Label{
            id: summaryHeadline
            text: qsTr("Summary:")

            font.bold:  true
            font.pixelSize: 17
            visible: summaryText ? true : false
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Material.foreground: Material.foreground
            Layout.topMargin: 10
            leftPadding: app.margins +10
            rightPadding: app.margins +10
        }

        Label{
            id: summary
            text: summaryText
            visible: summaryText ? true : false
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Material.foreground: Material.foreground
            leftPadding: app.margins +10
            rightPadding: app.margins +10
            Layout.bottomMargin: 15
            wrapMode: Text.WordWrap

        }
        // default explanation. Only used if the body is not implemented
        Label {
            id: textLabel
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            Layout.alignment: Qt.AlignVCenter

            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            lineHeight: 1.1
            Material.foreground: Material.foreground
            text: infotext
            leftPadding: app.margins +10
            rightPadding: app.margins +10
            topPadding: app.height/3
            visible: infotext && body !== null ? true: false

        }
        Item {
            id: bodyContainer
            clip: true
            Layout.fillWidth: true
            Layout.preferredWidth: app.width
            height: childrenRect.height
            visible: body !== null ? true : false
            Layout.bottomMargin: 15

        }
    }
    }



}
