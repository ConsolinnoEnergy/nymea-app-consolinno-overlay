import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtCharts 2.15
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Avoid Zero Compensation")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    Component.onCompleted: {
        let svgText = loadSvgText(picture.source)
        let id = getAllIds(svgText)
        var newSvg = replaceMultipleFills(svgText, id)
        picture.source = "data:image/svg+xml;utf8," + encodeURIComponent(newSvg);
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

    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout {
            id: bodyItem
            Label{
                id: labelID
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("On days with negative electricity prices, battery capacity is actively retained so that the battery can be charged during hours with negative electricity prices and feed-in without compensation is avoided. As soon as the control becomes active, the charging of the battery is limited (visible by the yellow message on the screen.) The control is based on the forecast of PV production and household consumption and postpones charging accordingly:")
            }

            Image {
                id: picture
                Layout.fillHeight: true
                Layout.preferredWidth: app.width
                Layout.topMargin: 35
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                sourceSize.width: 300
                sourceSize.height: 300
                fillMode: Image.PreserveAspectFit
                source: "../images/avoidZeroCompansation.svg"
            }

            ColumnLayout {
                anchors.top: picture.bottom
                anchors.horizontalCenter: picture.horizontalCenter
                anchors.topMargin: 5
                spacing: 8

                RowLayout {
                    spacing: 30
                    Layout.alignment: Qt.AlignHCenter

                    RowLayout {
                        spacing: 5
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: Style.marketPriceColor
                        }
                        Label {
                            text: qsTr("Market price")
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    RowLayout {
                        spacing: 5
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: Style.pvProductionColor
                        }
                        Label {
                            text: qsTr("PV production")
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    spacing: 5

                    RowLayout {
                        spacing: 5
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: Style.socWithoutControllerColor
                        }
                        Label {
                            text: qsTr("SoC without controller")
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    spacing: 5
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: Style.socWithControllerColor
                    }
                    Label {
                        text: qsTr("SoC with controller")
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

        }
    }
}
