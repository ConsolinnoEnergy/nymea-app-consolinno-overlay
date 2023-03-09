import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

Item {
    id: root
    implicitHeight: aboutColumn.implicitHeight

    property alias title: titleLabel.text
    property url githubLink

    property var additionalLicenses: null

    default property alias content: contentGrid.data

    ColumnLayout {
        id: aboutColumn
        anchors { left: parent.left; right: parent.right; top: parent.top }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Image {
                id: logo
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                fillMode: Image.PreserveAspectFit
                source: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)

                MouseArea {
                    anchors.fill: parent
                    property int clickCounter: 0
                    onClicked: {
                        clickCounter++;
                        if (clickCounter >= 10) {
                            settings.showHiddenOptions = !settings.showHiddenOptions
                            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                            var text = settings.showHiddenOptions
                                    ? qsTr("Developer options are now enabled. If you have found this by accident, it is most likely not of any use for you. It will just enable some nerdy developer gibberish in the app. Tap the icon another 10 times to disable it again.")
                                    : qsTr("Developer options are now disabled.")
                            var popup = dialog.createObject(app, {headerIcon: "../images/dialog-warning-symbolic.svg", title: qsTr("Howdy cowboy!"), text: text})
                            popup.open();
                            clickCounter = 0;
                        }
                    }
                }
            }

            Label {
                id: titleLabel
                font.pixelSize: app.largeFont
            }
        }

        ThinDivider {}

        GridLayout {
            id: contentGrid
            Layout.fillWidth: true
            columns: Math.max(1, root.width / 300)
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.bold: true
            text: "Copyright (C) %1 Consolinno Energy GmbH".arg(new Date().getFullYear())


        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
            text: qsTr("Licensed under the terms of the GNU General Public License, version 3. Please visit the GitHub page for source code and build instructions.")        }

        ColumnLayout {
            Layout.fillWidth: true

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                iconName: "../images/stock_website.svg"
                text: qsTr("Visit GitHub page")
                subText: Configuration.githubLink
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    Qt.openUrlExternally(Configuration.githubLink)
                }
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("View privacy policy")
                iconName: "../images/stock_website.svg"
                subText: Configuration.privacyPolicyUrl
                prominentSubText: false
                wrapTexts: false
                onClicked:
                    //pageStack.push("../info/Privacy/PrivacyPage.qml")
                    Qt.openUrlExternally(Configuration.privacyPolicyUrl)
            } 

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Common Licenses")
                iconName:  "../images/logs.svg"
                subText: qsTr("Only available on the local network")
                prominentSubText: false
                wrapTexts: false
                onClicked: {
                    var isRemote=function()
                    {
                        if  (["hems-demo.consolinno-it.de", ].includes(engine.jsonRpcClient.currentConnection.hostAddress.toString())) {
                            return true
                        }
                        if  (engine.jsonRpcClient.currentConnection.hostAddress.toString().includes("hems-remoteproxy")) {
                            return true
                        }
                        return false
                    }
                    if(isRemote()) {
                        localOnlyPopup.open()
                    }else{
                        Qt.openUrlExternally("http://" + engine.jsonRpcClient.currentConnection.hostAddress.toString() + ":8083" )
                    }
                }
            }

            Popup {
                id: localOnlyPopup
                parent: Overlay.overlay
                x: Math.round((parent.width - width) / 2)
                y: Math.round((parent.height - height) / 2)
                width: parent.width
                height: 100
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                contentItem: Label {
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("Only available on the local network. Please connect the device running this app to the same network as your Leaflet HEMS system, e.g. your home network.")
                }
            }
        }

        ThinDivider { }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Image {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: height
                fillMode: Image.PreserveAspectFit
                source: "qrc:/ui/images/Built_with_Qt_RGB_logo_vertical.svg"
                sourceSize.width: Style.iconSize * 2
                sourceSize.height: Style.iconSize * 2
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Qt is a registered trademark of The Qt Company Ltd. and its subsidiaries.")
                wrapMode: Text.WordWrap
            }
        }
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "../images/stock_website.svg"
            text: qsTr("Visit the Qt website")
            subText: "https://www.qt.io"
            prominentSubText: false
            wrapTexts: false
            onClicked: {
                Qt.openUrlExternally("https://www.qt.io")
            }
        }

        NymeaSwipeDelegate {
            Layout.fillWidth: true
            iconName: "../images/stock_website.svg"
            text: qsTr("Visit the nymea website")
            subText: "https://www.nymea.io"
            prominentSubText: false
            wrapTexts: false
            onClicked: {
                Qt.openUrlExternally("https://www.nymea.io")
            }
        }
    }


    Component {
        id: licensesPageComponent
        Page {
            id: licensesPage
            header: NymeaHeader {
                text: qsTr("Additional software licenses")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }

                Repeater {
                    model: root.additionalLicenses

                    delegate: NymeaSwipeDelegate {
                        Layout.fillWidth: true
                        text: model.component
                        subText: model.infoText
                        prominentSubText: false
                        visible: model.platforms === "*" ||  model.platforms.indexOf(Qt.platform.os) >= 0
                        onClicked: {
                            pageStack.push(licenseTextComponent, {license: model.license})
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
            header: NymeaHeader {
                text: parent.license
                onBackPressed: pageStack.pop()
            }

            property string license

            Flickable {
                anchors.fill: parent
                contentHeight: licenseText.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar {}
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
                                text = xhr.responseText
                            }
                        };
                        xhr.send();
                    }
                }
            }
        }
    }
}

