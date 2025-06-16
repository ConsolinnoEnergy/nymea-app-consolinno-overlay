import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Overload protection ")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The overload protection reduces the EV charging power in the event of an overload. The corresponding power or the nominal current of the house connection must be configured for this.")
            }
        }
    }
}

