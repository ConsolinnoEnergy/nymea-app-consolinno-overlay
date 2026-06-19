import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea

Item {
    id: root
    implicitHeight: layout.implicitHeight + bottomBorder.height + 2 * Style.mediumMargins
    property alias text: headline.text
    property alias subText: subHeadline.text
    property alias backButtonVisible: backButton.visible
    property alias menuButtonVisible: menuButton.visible
    default property alias children: layout.data
    property alias elide: headline.elide
    property alias wrapMode: headline.wrapMode

    // Optional. When set, a blurred snapshot of the top strip of this item is
    // drawn behind the header so scrolled content shows through. Typically the
    // Flickable whose content passes under the header.
    property Item blurSource: null

    signal backPressed();
    signal menuPressed();

    // If blurSource is a Flickable, sample its contentItem (regular Item) at
    // the scrolled position. Otherwise sample blurSource directly.
    readonly property bool _sourceIsFlickable: root.blurSource !== null
                                                && root.blurSource.hasOwnProperty("contentItem")
                                                && root.blurSource.hasOwnProperty("contentY")
    readonly property Item _effectiveSourceItem: root.blurSource === null
                                                 ? null
                                                 : (_sourceIsFlickable
                                                    ? root.blurSource.contentItem
                                                    : root.blurSource)
    readonly property real _effectiveSourceY: _sourceIsFlickable
                                              ? root.blurSource.contentY
                                              : 0

    ShaderEffectSource {
        id: headerBlurSource
        width: root.width
        height: root.height - bottomBorder.height
        sourceItem: root._effectiveSourceItem
        sourceRect: root.blurSource
                    ? Qt.rect(0, root._effectiveSourceY, width, height)
                    : Qt.rect(0, 0, 0, 0)
        recursive: true
        live: true
        visible: false
        enabled: root.blurSource !== null
    }

    Rectangle {
        id: blurBackdrop
        anchors.fill: parent
        anchors.bottomMargin: bottomBorder.height
        color: Style.backgroundColor
        visible: root.blurSource !== null
    }

    FastBlur {
        x: 0
        y: 0
        width: root.width
        height: root.height - bottomBorder.height
        source: headerBlurSource
        radius: 40
        transparentBorder: false
        visible: root.blurSource !== null
    }

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
            flat: true
            onClicked: root.backPressed();
        }

        Item {
            id: spacer
            visible: !backButton.visible
            width: backButton.implicitWidth
            height: backButton.implicitHeight
        }

        ColumnLayout {
            id: labelLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: layout.width - (backButton.visible ? backButton.width : 0) - (menuButton.visible ? menuButton.width : 0)
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
            flat: true
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
