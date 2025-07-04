import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml 2.2
import Nymea 1.0

Rectangle {
    Layout.fillWidth: true
    radius: 10
    color: Style.warningBackground
    border.width: 1
    border.color: Style.warningAccent
    implicitHeight: alertContainer.implicitHeight + 20

    ColumnLayout {
        id: alertContainer
        anchors.fill: parent
        spacing: 1

        Item {
            Layout.preferredHeight: 10
        }


        RowLayout {
            width: parent.width
            height: parent.height
            spacing: 5

            Item {
                Layout.preferredWidth: 10
            }

            Image {
                id: image
                sourceSize: Qt.size(24, 24)
                source: "../images/attention.svg"
            }

            Label {
                font.pixelSize: 16
                text: qsTr("Avoid zero compensation active")
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 20
                color: Style.warningAccent
            }

            ColorOverlay {
                anchors.fill: image
                source: image
                color: "#864A0D"
            }

        }

        MouseArea {
            Layout.fillWidth: true
            Layout.preferredWidth: alertContainer.width - 20
            height: screenGuideText.height + (app.width >= 400 ? 15 : 40)

            Label {
                id: screenGuideText
                font.pixelSize: 16
                text: qsTr("Battery charging is limited while the controller is active. <u>More Information</u>")
                wrapMode: Text.WordWrap
                width: alertContainer.width - 20
                leftPadding: 40
                color: Style.warningAccent
            }

            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/ConsolinnoDialog.qml"));
                var text = qsTr("On days with negative electricity prices, battery capacity is actively retained so that the battery can be charged during hours with negative electricity prices and feed-in without compensation is avoided. As soon as the control becomes active, the charging of the battery is limited (visible by the yellow message on the screen.) The control is based on the forecast of PV production and household consumption and postpones charging accordingly:")
                var popup = dialog.createObject(app, {headerText: qsTr("Avoid zero compensation"), text: text, source: "../images/avoidZeroCompansation.svg", picHeight: 280})
                popup.open();
            }
        }

        Item {
            Layout.preferredHeight: 10
        }
    }
}
