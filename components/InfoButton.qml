import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import QtGraphicalEffects 1.15
import QtQuick.Controls.Material 2.12
import Nymea 1.0

import "../components"
import "../delegates"

Item {
    property var push
    property var stack
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
        color: Style.colors.brand_Basic_Icon
    }

}

