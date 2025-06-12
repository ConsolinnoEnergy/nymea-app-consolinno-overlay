import QtQuick 2.12
import QtQuick.Controls 2.12

Image {
    id: image
    sourceSize: Qt.size(image.width, image.height)

    Image {
        id: hiddenImg
        source: parent.source
        width: 0
        height: 0
    }
}
