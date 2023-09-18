import QtQuick 2.15
import "qrc:/ui/components"
import Nymea 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

Page {
    id: root

    property alias content: contentContainer.children
    property alias showNextButton: nextButton.visible
    property alias nextButtonText: nextLabel.text
    property alias showBackButton: backButton.visible
    property alias backButtonText: backLabel.text
    property alias showExtraButton: extraButton.visible
    property alias extraButtonText: extraButtonLabel.text

    property bool headerVisible: true
    property bool headerBackButtonVisible: true
    property string headerLabel: ""

    signal next();
    signal back();
    signal extraButtonPressed();
    signal done(bool skip, bool abort);

    header: NymeaHeader {
        text: root.headerLabel
        visible: root.headerVisible
        backButtonVisible: root.headerBackButtonVisible
        onBackPressed:{
            pageStack.pop()
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

                Rectangle{
                    id: extraButton

                    anchors.centerIn: parent
                    width: extraButtonLabel.width +15
                    height: extraButtonLabel.height +10
                    color: "#87BD26"
                    border.width: 1
                    border.color: "black"
                    radius: 4
                    visible: false

                    MouseArea {

                        anchors.centerIn: parent
                        height: Style.delegateHeight +10
                        width: childrenRect.width +15

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

