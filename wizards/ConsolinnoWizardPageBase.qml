import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import "../components"

Page {
    id: root

    background: Rectangle { color: Style.colors.typography_Background_Default }
    bottomPadding: 0

    property bool backButtonVisible: true
    property string headerLabel: ""
    property real headerHeight: header.height
    property var backAction: function() { pageStack.pop() }
    property int navigationFooterHeight: 0

    onHeightChanged: {
        if (PlatformHelper.imeHeight <= 0) return;
        var focused = Window.activeFocusItem;
        if (!focused) return;

        // Walk up through parent chain to find a Flickable (duck-typed by contentY + flickableDirection)
        var item = focused.parent;
        var flickable = null;
        while (item && item !== root) {
            if ("contentY" in item && "flickableDirection" in item) {
                flickable = item;
                break;
            }
            item = item.parent;
        }
        if (!flickable) return;

        var itemPos = focused.mapToItem(flickable.contentItem, 0, focused.height);
        var itemBottom = itemPos.y;
        var usableHeight = flickable.height - root.navigationFooterHeight;
        var visibleBottom = flickable.contentY + usableHeight;

        if (itemBottom > visibleBottom) {
            flickable.contentY = itemBottom - usableHeight + Style.margins;
        }
    }

    header: null
    footer: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        text: root.headerLabel
        backButtonVisible: root.backButtonVisible
        wrapMode: Text.WordWrap
        onBackPressed:{
            root.backAction()
        }
    }
}

