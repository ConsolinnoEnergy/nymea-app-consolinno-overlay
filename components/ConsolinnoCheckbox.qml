import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import Nymea 1.0

RowLayout{
    id: root
    property string text
    property bool checked: checkbox.checked

    CheckBox{
        id: checkbox
        Layout.alignment: Qt.AlignHCenter
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
        text: root.text
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(!checkbox.checked){
                    checkbox.checked = true
                }else{
                    checkbox.checked = false
                }
            }
        }
    }
}
