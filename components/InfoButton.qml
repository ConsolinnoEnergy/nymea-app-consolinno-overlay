import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Controls.Styles 1.4
import QtQml
import Qt5Compat.GraphicalEffects
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    property var push
    property var stack
    property var infoProperties: ({})
    implicitWidth: 18
    implicitHeight: 18
    Image{
        id: infoImage
        anchors.fill: parent
        source: "/icons/info.svg"
        MouseArea{
            anchors.fill: parent
            onClicked:{
                if (push)
                {
                    if (stack)
                    {
                        stack.push("../info/" + push, Object.assign({stack: stack}, infoProperties))

                    }
                    else{
                        pageStack.push("../info/" + push, Object.assign({stack: pageStack}, infoProperties))
                    }
                }
            }
        }
    }
    ColorOverlay{
        anchors.fill: infoImage
        source: infoImage
        color: Style.colors.brand_Basic_Icon
    }

}

