import QtQuick 2.4
import QtGraphicalEffects 1.0
import Nymea 1.0

Item {
    id: icon
    width: size
    height: size
    implicitHeight: image.implicitHeight
    implicitWidth: image.implicitWidth

    property alias name: icon.source
    property string source
    property alias color: colorOverlayID.outColor
    property int margins: 0
    property int size: Style.iconSize

    property alias status: image.status

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: parent ? parent.margins : 0
        source: width > 0 && height > 0 && icon.source ?
                    icon.source.endsWith(".svg") ? icon.source
                                               : "qrc:/ui/images/" + icon.source + ".svg"
                                                 : ""
        sourceSize {
            width: width
            height: height
        }
        cache: true
    }

    ColorOverlay {
        id: colorOverlayID
        property color outColor: Style.iconColor
        anchors.fill: image
        source: image
        color: outColor
        z: 3
    }
}
