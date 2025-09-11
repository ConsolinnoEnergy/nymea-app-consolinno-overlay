import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml 2.2
import Nymea 1.0

import "qrc:/ui/devicepages"

Rectangle {
    property color backgroundColor
    property color borderColor
    property color textColor
    property color iconColor

    property string imagePath
    property string dialogHeaderText
    property string dialogText
    property string dialogPicture

    property string pagePath: ""
    property string pageUrl: ""
    property var paramsThing: ({})
    property string pageStartView
    property string iconPath
    property alias text: screenGuideText.text
    property alias headerText: header.text

    Layout.fillWidth: true
    radius: 10
    color: backgroundColor
    border.width: 1
    border.color: borderColor
    implicitHeight: alertContainer.implicitHeight

    ColumnLayout {
        id: alertContainer
        anchors.fill: parent
        spacing: 1

        Item {
            Layout.preferredHeight: 12
        }


        RowLayout {
            width: parent.width
            height: parent.height
            spacing: 0

            Image {
                id: image
                sourceSize: Qt.size(24, 24)
                source: iconPath === "" ? "../images/attention.svg" : iconPath
                Layout.leftMargin: 12
                Layout.rightMargin: 8
            }

            Label {
                id: header
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 20
                color: textColor
            }

            ColorOverlay {
                anchors.fill: image
                source: image
                color: iconColor
            }

        }

        MouseArea {
            Layout.fillWidth: true
            Layout.preferredWidth: alertContainer.width - 20
            Layout.preferredHeight: screenGuideText.height
            Layout.leftMargin: 12

            Label {
                id: screenGuideText
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                width: alertContainer.width - 20
                leftPadding: 33
                color: textColor
            }

            onClicked: {
                if(imagePath.length > 0){
                    var dialog = Qt.createComponent(Qt.resolvedUrl(imagePath));
                    var text = dialogText
                    var popup = dialog.createObject(app, {headerText: dialogHeaderText, text: text, source: dialogPicture, picHeight: 280})
                    popup.open();
                }else if(pageUrl.length > 1){
                    console.error(JSON.stringify(paramsThing))
                    pageStack.push(Qt.resolvedUrl(pageUrl), JSON.stringify(paramsThing))
                }else if(pagePath.length > 1){
                    pageStack.push(Qt.resolvedUrl(pagePath), {startView: pageStartView})
                }
            }
        }

        Item {
            Layout.preferredHeight: 12
        }
    }
}
