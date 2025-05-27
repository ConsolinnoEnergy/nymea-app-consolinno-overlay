import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtQml 2.2

Rectangle {
    Layout.fillWidth: true
    radius: 10
    color: "#FFEE89"
    border.width: 1
    border.color: "#864A0D"
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
                color: "#FFEE89"
                border.color: "#864A0D"
                border.width: 1
                RowLayout.alignment: Qt.AlignVCenter

                Label {
                    text: "!"
                    anchors.centerIn: parent
                    color: "#864A0D"
                }
            }

            Label {
                font.pixelSize: 16
                text: qsTr("Avoid zero compensation active")
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 20
                color: "#864A0D"
            }
        }
        Label {
            font.pixelSize: 16
            text: qsTr("The battery charge is limited during regulation. <u>More Information</u>")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - 20
            leftPadding: 40
            color: "#864A0D"
        }

        Item {
            Layout.preferredHeight: 10
        }
    }
}
