import QtQuick 2.0
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.3


Item {
    property var push
    Image{
        id: infoImage
        sourceSize.width: 18
        sourceSize.height: 18
        source: "../images/info.svg"
        MouseArea{
            anchors.fill: parent
            onClicked:{
                if (push)
                {
                    pageStack.push("../info/" + push)
                }
            }
        }
    }
    ColorOverlay{
        anchors.fill: infoImage
        source: infoImage
        color: "black"
    }

}
