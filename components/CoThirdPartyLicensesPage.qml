import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("About %1").arg(Configuration.systemName)
    coHeader.subText: qsTr("Software and libraries (App)")

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        Repeater {
            model: Configuration.thirdPartyComponents

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: model.name
                contentTopMargin: Style.smallMargins

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Project website")
                        helpText: model.url
                        showChildrenIndicator: true
                        onClicked: {
                            Qt.openUrlExternally(model.url)
                        }
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: model.licenseName
                        // #TODO URL to License as helpText?
                        showChildrenIndicator: true
                        onClicked: {
                            pageStack.push(licenseTextComponent, {licenseFull: model.licenseName, license: model.license })
                        }
                    }
                }
            }
        }
    }

    Component {
        id: licenseTextComponent
        Page {
            id: licenseTextPage
            bottomPadding: 0
            property int navigationFooterHeight: 0

            property string licenseFull
            property string license

            header: null

            CoHeader {
                id: header
                anchors { left: parent.left; right: parent.right; top: parent.top }
                z: 1
                blurSource: bodyFlickable
                text: licenseTextPage.licenseFull
                onBackPressed: pageStack.pop()
            }

            Flickable {
                id: bodyFlickable
                anchors.fill: parent
                topMargin: header.height
                contentHeight: licenseText.implicitHeight + licenseTextPage.navigationFooterHeight
                clip: true
                ScrollBar.vertical: null

                Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

                TextArea {
                    id: licenseText
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    anchors { left: parent.left; right: parent.right; margins: app.margins }
                    readOnly: true
                    Component.onCompleted: {
                        var xhr = new XMLHttpRequest;
                        xhr.open("GET", "../../LICENSE." + licenseTextPage.license);
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                text = xhr.responseText;
                            }
                        };
                        xhr.send();
                    }
                }
            }
        }
    }
}