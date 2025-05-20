import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.15
import Nymea 1.0
import "../components"
import "../delegates"

Rectangle {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    radius: 10
    color: "#1AF37B8E"
    border.width: 1
    border.color: "#F37B8E"
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
        spacing: 2

        Canvas {
            id: triangle
            width: 20
            height: 17
            RowLayout.leftMargin: 13
            anchors.bottom: attentionLabel.baseline

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.beginPath();
                ctx.moveTo(width/2, 0);
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.closePath();

                ctx.fillStyle = "#1AF37B8E";
                ctx.fill();

                ctx.lineWidth = 1;
                ctx.strokeStyle = "#F37B8E";
                ctx.stroke();
            }
        }

        Label {
            font.pixelSize: 13
            text: "!"
            anchors.centerIn: triangle
            font.bold: true
            color: "#F37B8E"
        }

        Label {
            id: attentionLabel
            font.pixelSize: 16
            text: qsTr("Attention")
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - 20
        }
    }

        Label {
            font.pixelSize: 16
            text: qsTr("Existing set-up will be overwritten.")
            wrapMode: Text.WordWrap
            Layout.rightMargin: 20
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - 20
            leftPadding: 40
        }

        Item {
            Layout.preferredHeight: 10
        }
    }
}

