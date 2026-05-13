import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

Item {
    id: root
    implicitHeight: layout.implicitHeight + bottomBorder.implicitHeight + 2 * Style.mediumMargins
    property alias text: headline.text
    property alias subText: subHeadline.text
    property alias backButtonVisible: backButton.visible
    property alias menuButtonVisible: menuButton.visible
    default property alias children: layout.data
    property alias elide: headline.elide
    property alias wrapMode: headline.wrapMode

    signal backPressed();
    signal menuPressed();

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.bottomMargin: bottomBorder.height
        color: Style.colors.menu_Header_Footer_Background
    }

    RowLayout {
        id: layout
        spacing: Style.margins
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            topMargin: Style.mediumMargins
            leftMargin: Style.smallMargins
            rightMargin: Style.margins
        }

        RoundButton {
            id: backButton
            icon.source: "qrc:/icons/arrow_back_ios_new.svg"
            secondary: true
            onClicked: root.backPressed();
        }

        ColumnLayout {
            id: labelLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: layout.width - backButton.width - (menuButton.visible ? menuButton.width : 0)
            spacing: 0

            Label {
                id: headline
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                font: Style.newH3Font
                color: Style.colors.typography_Basic_Default
            }

            Label {
                id: subHeadline
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: text !== ""
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                text: ""
                font: Style.newExtraSmallFont
                color: Style.colors.typography_Basic_Default
            }
        }


        RoundButton {
            id: menuButton
            icon.source: "qrc:/icons/menu.svg"
            visible: false
            secondary: true
            onClicked: root.menuPressed();
        }
    }

    Rectangle {
        id: bottomBorder
        anchors {
            right: parent.right
            left: parent.left
            top: layout.bottom
            topMargin: Style.mediumMargins
        }
        height: 1
        color: Style.colors.menu_Header_Footer_Border
    }
}
