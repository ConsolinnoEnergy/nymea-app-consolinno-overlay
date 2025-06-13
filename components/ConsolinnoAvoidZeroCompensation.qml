import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
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
                color: "#864A0D"
            }

            ColorOverlay {
                anchors.fill: image
                source: image
                color: "#864A0D"
            }

        }
        Label {
            font.pixelSize: 16
            text: qsTr("The battery charge is limited during regulation.")
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
