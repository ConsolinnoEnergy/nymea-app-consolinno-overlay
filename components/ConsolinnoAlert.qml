import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQml 2.2

Rectangle {
    property color backgroundColor // "#FFEE89"
    property color borderColor // "#864A0D"
    property color textColor // #864A0D"
    property color iconColor // "#864A0D"

    property string iconPath // "../components/ConsolinnoDialog.qml"
    property string dialogHeaderText //"Avoid zero compensation"
    property string dialogText // qsTr("On days with negative electricity prices, battery capacity is actively retained so that the battery can be charged during hours with negative electricity prices and feed-in without compensation is avoided. As soon as the control becomes active, the charging of the battery is limited (visible by the yellow message on the screen.) The control is based on the forecast of PV production and household consumption and postpones charging accordingly:")
    property string dialogPicture // "../images/avoidZeroCompansation.svg"

    property alias text: screenGuideText.text //text: qsTr("Battery charging is limited while the controller is active. <u>More Information</u>")
    property alias headerText: header.text //text: qsTr("Avoid zero compensation active")

    Layout.fillWidth: true
    radius: 10
    color: backgroundColor
    border.width: 1
    border.color: borderColor
    implicitHeight: alertContainer.implicitHeight

    ColumnLayout {
        id: alertContainer
        anchors.fill: parent
        spacing: 1

        Item {
            Layout.preferredHeight: 12
        }


        RowLayout {
            width: parent.width
            height: parent.height
            spacing: 5

            Item {
                Layout.preferredWidth: 6
            }

            Image {
                id: image
                sourceSize: Qt.size(24, 24)
                source: "../images/attention.svg"
            }

            Label {
                id: header
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 20
                color: textColor
            }

            ColorOverlay {
                anchors.fill: image
                source: image
                color: iconColor
            }

        }

        MouseArea {
            Layout.fillWidth: true
            Layout.preferredWidth: alertContainer.width - 20
            Layout.preferredHeight: screenGuideText.height

            Label {
                id: screenGuideText
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                width: alertContainer.width - 20
                leftPadding: 40
                color: textColor
            }

            onClicked: {
                if(iconPath.length > 0){
                    var dialog = Qt.createComponent(Qt.resolvedUrl(iconPath));
                    var text = dialogText
                    var popup = dialog.createObject(app, {headerText: dialogHeaderText, text: text, source: dialogPicture, picHeight: 280})
                    popup.open();
                }
            }
        }

        Item {
            Layout.preferredHeight: 12
        }
    }
}
