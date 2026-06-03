import QtQuick
import "../dependencies/QR-Code-Generator-QML"

Item {
    id: root
    property string content: ""
    property url logoSource: ""
    property real logoSizeRatio: 0.25

    implicitWidth: 256
    implicitHeight: 256

    QRGenerator {
        id: qrGenerator
        content: root.content !== "" ? root.content : " "
        ecl: root.logoSource != "" ? "H" : "M"
        join: true
        xmlDeclaration: false
    }

    Image {
        anchors.fill: parent
        source: qrGenerator.svgString !== "" ? "data:image/svg+xml;utf8," + encodeURIComponent(qrGenerator.svgString) : ""
        smooth: false
    }

    Rectangle {
        visible: root.logoSource != ""
        anchors.centerIn: parent
        width: parent.width * root.logoSizeRatio + 8
        height: width
        color: "white"
        radius: 4

        Image {
            anchors.centerIn: parent
            width: parent.width - 8
            height: parent.height - 8
            source: root.logoSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            sourceSize.width: width
            sourceSize.height: height
        }
    }
}
