import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtCharts 2.15
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Avoid Zero Compensation")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout {
            id: bodyItem
            Label{
                id: labelID
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("On days with negative electricity prices, battery capacity is actively retained so that the battery can be charged during hours with negative electricity prices and feed-in without compensation is avoided. As soon as the control becomes active, the charging of the battery is limited (visible by the yellow message on the screen.) The control is based on the forecast of PV production and household consumption and postpones charging accordingly:")
            }

            Image {
                id: picture
                Layout.fillHeight: true
                Layout.preferredWidth: app.width
                Layout.topMargin: 35
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                sourceSize.width: 300
                sourceSize.height: 300
                fillMode: Image.PreserveAspectFit
                source: Qt.locale("de_DE") ? "../images/avoidZeroCompansationExample_de.svg" : "../images/avoidZeroCompansationExample_en.svg"
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

        }
    }
}
