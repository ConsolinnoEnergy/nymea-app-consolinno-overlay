import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import Nymea 1.0

import "../components"
import "../delegates"

ColumnLayout{
    id: statusSign
    property var enabled
    property var pluggedIn
    property var state
    property var idle
    Layout.fillWidth: true
    spacing: 0
    visible: enabled

    Rectangle{
        id: status

        //initiation   // yellow
        //running      // green
        //toBeCanceled // lightblue
        //canceled     // blue
        //notdefined   // white
        //disabled     // lightgrey
        //pausiert     // orange

        width: 17
        height: 17

        Layout.alignment: Qt.AlignRight

        //check if plugged in                 check if current power == 0           else show the current state the session is in atm
        color: pluggedIn ? (idle ? (state === 1 ? "yellow" : (state === 2 ? "green" : (state === 3 ? "blue" : "lightgrey") ) ) : "orange") : "red"
        //color:  pluggedIn ? (idle ? (state === 1 ? "yellow" : (state === 2 ? "green" : (state === 3 ? "blue" : (state === 4 ? "lightgrey" : "white" ) ) )   )   : "orange" ) : "lightgrey"

        border.color: "black"
        border.width: 1
        radius: width*0.5
    }
    Label{
        id: description
        text: state
        //text: state === 1 ? "Initialising" : (state === 2 ? "Running" : (state === 3 ? "Finished" : (state.state === 4 ? "Interrupted" :  "Failed"  )))
        Layout.alignment: Qt.AlignRight
    }

}
