import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.15
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    id: root
    implicitHeight: layout.implicitHeight + infoPane.height
    property string text
    property bool show_Image: false
    property alias backButtonVisible: backButton.visible
    property var backButtonColor: Material.accent

    property alias menuButtonVisible: menuButton.visible

    default property alias children: layout.data
    property alias elide: label.elide

    signal backPressed();
    signal menuPressed();

    function showInfo(text, isError, isSticky) {
        if (isError === undefined) isError = false;
        if (isSticky === undefined) isSticky = false;

        infoPane.text = text;
        infoPane.isError = isError;
        infoPane.isSticky = isSticky;

        if (!isSticky) {
            infoPaneTimer.start();
        }
    }


    RowLayout {
        id: layout
        anchors { left: parent.left; top: parent.top; right: parent.right }

        HeaderButton {
            id: menuButton
            objectName: "headerMenuButton"
            imageSource: "../images/navigation-menu.svg"
            visible: false
            onClicked: root.menuPressed();
        }

        HeaderButton {
            id: backButton
            objectName: "backButton"
            imageSource: "../images/back.svg"
            onClicked: root.backPressed();
            color: root.backButtonColor


        }

        Item {
            id: fillerItem
            Layout.minimumWidth: layout.width/2 - label.width/2 - backButton.width - app.margins
        }
        Label {
            id: label
            //anchors.fill: parent
            //Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            //Layout.maximumWidth: layout.width - x * 2
            //Layout.minimumWidth: layout.width/2
            horizontalAlignment: Text.AlignHCenter
            //verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: root.text
            font: Style.bigFont
        }

        Image{
            id: headerImage
            sourceSize.width: 18
            sourceSize.height: 18
            source: "../images/info.svg"
            visible: show_Image
            layer{
                enabled: true
                effect: ColorOverlay{
                    color: Material.foreground
                }

            }
        }

        Rectangle{
            color: Material.background
            Layout.fillWidth: true
        }







    }


    Pane {
        id: infoPane
        Material.elevation: 1

        property string text
        property bool isError: false
        property bool isSticky: false
        property bool shown: isSticky || infoPaneTimer.running

        visible: height > 0
        height: shown ? contentRow.implicitHeight : 0
        Behavior on height { NumberAnimation {} }
        anchors { left: parent.left; top: layout.bottom; right: parent.right }

        padding: 0
        contentItem: Rectangle {
            color: infoPane.isError ? "red" : Style.accentColor
            implicitHeight: contentRow.implicitHeight
            RowLayout {
                id: contentRow
                anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
                Item {
                    Layout.fillWidth: true
                    height: Style.iconSize
                }

                Label {
                    text: infoPane.text
                    font.pixelSize: app.smallFont
                    color: "white"
                }

                ColorIcon {
                    height: Style.iconSize / 2
                    width: height
                    visible: true
                    color: "white"
                    name: "../images/dialog-warning-symbolic.svg"
                }
            }
        }
    }

    Timer {
        id: infoPaneTimer
        interval: 5000
        repeat: false
        running: false
    }
}
