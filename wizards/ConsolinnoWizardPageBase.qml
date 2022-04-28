import QtQuick 2.9
import "qrc:/ui/components"
import Nymea 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2


Page {
    id: root

    property alias headerBackgroundColor: topCircle.color

    property alias content: contentContainer.children

    property alias showNextButton: nextButton.visible
    property alias nextButtonText: nextLabel.text
    property alias showBackButton: backButton.visible
    property alias backButtonText: backLabel.text
    property alias showExtraButton: extraButton.visible
    property alias extraButtonText: extraButtonLabel.text

    signal next();
    signal back();
    signal extraButtonPressed();
    signal done(bool skip, bool abort);

    header: Item {

        height: 105

        Rectangle {
            anchors.centerIn: topCircle
            anchors.horizontalCenterOffset: 5
            anchors.verticalCenterOffset: 5
            radius: width/2
            width: topCircle.width
            height: topCircle.height
            color: Style.consolinnoLight
        }

        Rectangle {
            id: topCircle
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 5

                leftMargin: -parent.width / 2
                rightMargin: -parent.width / 2
            }
            height: width
            radius: width/2
            color: "#dddddd"

        }
        Image {
            anchors {
                fill: parent
                topMargin: Style.margins
                bottomMargin: Style.margins
                leftMargin: Style.bigMargins
                rightMargin: Style.bigMargins
            }
            fillMode: Image.PreserveAspectFit
//            source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
            source: "qrc:/styles/light/logo-wide.svg"
        }
    }

    background: Item {


        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: Style.hugeMargins
            gradient: Gradient {
                GradientStop { position: 0; color: Style.backgroundColor }
                GradientStop { position: 1; color: Style.accentColor }
            }
            Image {
                anchors.centerIn: parent
                width: Math.min(parent.width, 700)
                height: parent.height
                source: "/ui/images/intro-bg-graphic.svg"
                sourceSize.width: width
                fillMode: Image.PreserveAspectCrop
                verticalAlignment: Image.AlignTop
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.margins

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins

            MouseArea {
                id: backButton
                Layout.preferredHeight: Style.delegateHeight
                Layout.preferredWidth: childrenRect.width
                Layout.alignment: Qt.AlignLeft
                RowLayout {
                    anchors.centerIn: parent
                    ColorIcon {
                        Layout.alignment: Qt.AlignRight
                        size: Style.iconSize
                        name: "back"
                    }
                    Label {
                        id: backLabel
                        Layout.fillWidth: true
                        text: qsTr("Back")
                    }
                }
                onClicked: root.back()
            }


            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.delegateHeight
                MouseArea {
                    id: extraButton
                    anchors.centerIn: parent
                    height: Style.delegateHeight
                    width: childrenRect.width
                    visible: false
                    RowLayout{
                    anchors.centerIn: parent
                        Label {
                        id: extraButtonLabel
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter


                        }
                    }
                    onClicked: root.extraButtonPressed()
                }
            }


            MouseArea {
                id: nextButton
                Layout.preferredHeight: Style.delegateHeight
                Layout.preferredWidth: childrenRect.width
                Layout.alignment: Qt.AlignRight
                RowLayout {
                    anchors.centerIn: parent
                    Label {
                        id: nextLabel
                        Layout.fillWidth: true
                        text: qsTr("Next")
                    }
                    ColorIcon {
                        Layout.alignment: Qt.AlignRight
                        size: Style.iconSize
                        name: "next"
                    }
                }
                onClicked: root.next()
            }
        }
    }
}
