import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Price limit")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The price limit is defined based on the average price, e.g. average price -10%. This means that charging takes place as soon as the price is cheaper than the average price -10% calculated for the day. The price limit is valid until a new price limit is entered, even after unplugging and plugging in again.")
            }

        }

    }

}

