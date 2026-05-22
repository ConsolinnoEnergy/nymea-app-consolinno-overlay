import QtQuick
import "../dependencies/QR-Code-Generator-QML"

Item {
    id: root
    property string content: ""

    implicitWidth: 256
    implicitHeight: 256

    QRGenerator {
        id: qrGenerator
        content: root.content !== "" ? root.content : " "
        join: true
        xmlDeclaration: false
    }

    Image {
        anchors.fill: parent
        source: qrGenerator.svgString !== "" ? "data:image/svg+xml;utf8," + qrGenerator.svgString : ""
        smooth: false
    }
}
