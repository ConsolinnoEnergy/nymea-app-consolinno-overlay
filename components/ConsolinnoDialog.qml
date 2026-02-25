import QtQuick
import QtQuick.Window 2.15
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

Dialog {
    id: root
    width: Math.min(parent.width * .9, Math.max(contentLabel.implicitWidth, 500))
    height: 600
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property bool isMobile: Screen.width <= 768

    background: Rectangle {
        color: "white"
        radius: 10
        border.color: "#999"
        border.width: 1
        clip: true
        implicitWidth: root.width
        implicitHeight: root.height
    }


    property alias headerIcon: headerColorIcon.name
    property alias text: contentLabel.text
    property alias headerText: contentHeader.text
    property alias source: picture.imgSource
    default property alias children: content.children
    property int picHeight

    footer: Item {
        implicitHeight: app.margins
        implicitWidth: parent.width
        Layout.topMargin: 10
        RowLayout {
            id: buttonRow
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin: app.margins
                bottomMargin: app.margins
            }

            Button {
                Layout.topMargin: 5
                text: qsTr("OK")
                onClicked: {
                    root.destroy()
                }
            }
        }
    }

    onClosed: root.destroy()

    Connections {
        target: root.parent
        onDestroyed: root.destroy()
    }

    MouseArea {
        parent: app.overlay
        anchors.fill: parent
        z: -1
        onPressed: {
            mouse.accepted = true
        }
    }

    Component.onCompleted: {
        let svgText = loadSvgText(source)
        let id = getAllIds(svgText)
        var newSvg = replaceMultipleFills(svgText, id)
        picture.imgSource = "data:image/svg+xml;utf8," + encodeURIComponent(newSvg);
    }

    function loadSvgText(url) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, false);
        xhr.send();
        if (xhr.status === 200 || xhr.status === 0) {
            return xhr.responseText;
        } else {
            console.error("Fehler beim Laden der SVG:", xhr.status, xhr.statusText);
            return null;
        }
    }

    function replaceFillForId(svgText, targetId, newColor) {
        var pattern = new RegExp('(id\\s*=\\s*"' + targetId + '"[^>]*fill\\s*=\\s*")([^"]+)(")', 'g');
        return svgText.replace(pattern, '$1' + newColor + '$3');
    }

    function replaceMultipleFills(svgText, replacements) {
        var result = svgText;
        let newColor = "";
        for (var i = 0; i < replacements.length; ++i) {
            var pair = replacements[i];

            if(pair.id === "Market price line"){
                newColor = Style.marketPriceColor
            }else if(pair.id === "Soc without controller"){
                newColor = Style.socWithoutControllerColor
            }else if(pair.id === "SoC with controller"){
                newColor = Style.socWithControllerColor
            }else if(pair.id === "PV production"){
                newColor = Style.pvProductionColor
            }else if(pair.id === "Xaxis"){
                newColor = Style.xAxisColor
            }else if(pair.id === "Yaxis"){
                newColor = Style.yAxisColor
            }else{
                newColor = Style.arrowColor
            }

            result = replaceFillForId(result, pair.id, newColor);
        }
        return result;
    }

    function getAllIds(svgText) {
        var results = [];
        var regex = /<[^>]*\sid\s*=\s*"([^"]+)"[^>]*\sfill\s*=\s*"([^"]+)"[^>]*>/g;
        var match;
        while ((match = regex.exec(svgText)) !== null) {
            results.push({ id: match[1], fill: match[2] });
        }
        return results;
    }

    header: Item {
        implicitHeight: headerRow.height + app.margins
        implicitWidth: parent.width
        visible: root.title.length > 0
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins

            ColorIcon {
                id: headerColorIcon
                Layout.preferredHeight: Style.hugeIconSize
                Layout.preferredWidth: height
                color: Style.accentColor
                visible: name.length > 0
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }
    contentItem: Flickable {
        id: content
        clip: true
        anchors.margins: app.margins
        anchors.fill: parent
        contentHeight: container.implicitHeight + 20


        ColumnLayout {
            id: container
            width: content.width

            Label {
                id: contentHeader
                Layout.fillWidth: true
                font.pixelSize: app.largeFont
                Layout.preferredWidth: height
                font.bold: true
                wrapMode: "WordWrap"
                visible: headerText.length > 0
            }

            Label {
                id: contentLabel
                Layout.fillWidth: true
                font.pixelSize: 14
                wrapMode: "WordWrap"
                visible: text.length > 0
            }

            ImageSVGHelper {
                id: picture
                Layout.topMargin: 10
                Layout.bottomMargin: 50
                Layout.alignment: Qt.AlignHCenter
                imgHeight: picHeight
                imgSource: source
            }

            ColumnLayout {
                anchors.top: picture.bottom
                anchors.horizontalCenter: picture.horizontalCenter
                anchors.topMargin: 5
                spacing: 8
                Layout.bottomMargin: 10

                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter
                    RowLayout {
                        spacing: 5
                        Layout.rightMargin: 35
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 7
                            color: Style.marketPriceColor
                        }
                        Label {
                            text: qsTr("Market price")
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    RowLayout {
                        spacing: 5
                        Layout.rightMargin: 30
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 7
                            color: Style.pvProductionColor
                        }
                        Label {
                            text: qsTr("PV production")
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    RowLayout {
                        spacing: 5
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 7
                            color: Style.socWithoutControllerColor
                        }
                        Label {
                            text: qsTr("SoC without controller")
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    Rectangle {
                        width: 13
                        height: 13
                        radius: 7
                        color: Style.socWithControllerColor
                    }
                    Label {
                        text: qsTr("SoC with controller")
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    Rectangle {
        parent: app.overlay
        anchors.fill: parent
        color: "#99303030"
    }
}
