import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//import QtQuick.Controls.Styles 1.4
import QtQml
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    property var push
    property var stack
    Image{
        id: infoImage
        sourceSize.width: 18
        sourceSize.height: 18
        source: "/icons/info.svg"
        MouseArea{
            anchors.fill: parent
            onClicked:{
                if (push)
                {
                    if (stack)
                    {
                        stack.push("../info/" + push, {stack: stack})

                    }
                    else{
                        pageStack.push("../info/" + push, {stack: pageStack})
                    }
                }
            }
        }
    }
    ColorOverlay{
        anchors.fill: infoImage
        source: infoImage
        color: Material.foreground
    }

}

