import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
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
            spacing: 5

            Item {
                Layout.preferredWidth: 10
            }

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: Style.warningBackground
                border.color: Style.warningAccent
                border.width: 1
                RowLayout.alignment: Qt.AlignVCenter

                Label {
                    text: "!"
                    anchors.centerIn: parent
                    color: Style.warningAccent
                }
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
        }

        MouseArea {
            Layout.fillWidth: true
            Layout.preferredWidth: alertContainer.width - 20
            height: screenGuideText.height + (app.width >= 400 ? 15 : 30)

            Label {
                id: screenGuideText
                font.pixelSize: 16
                text: qsTr("The battery charge is limited during regulation. <u>More Information</u>")
                wrapMode: Text.WordWrap
                width: alertContainer.width - 20
                leftPadding: 40
                color: Style.warningAccent
            }

            onClicked: {
                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/ConsolinnoDialog.qml"));
                var text = qsTr("On days with negative electricity prices, battery capacity is actively retained so that the battery can be charged during hours with negative electricity prices and feed-in without compensation is avoided. As soon as the control becomes active, the charging of the battery is limited (visible by the yellow message on the screen.) The control is based on the forecast of PV production and household consumption and postpones charging accordingly:")
                var popup = dialog.createObject(app, {text: text, source: Qt.locale("de_DE") ? "../images/avoidZeroCompansationExample_de.svg" : "../images/avoidZeroCompansationExample_en.svg"})
                popup.open();
            }
        }

        Item {
            Layout.preferredHeight: 10
        }
    }
}
