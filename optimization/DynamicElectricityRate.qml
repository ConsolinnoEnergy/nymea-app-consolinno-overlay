import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root
    property HemsManager hemsManager

    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic Electricity Rate")
        backButtonVisible: true
        onBackPressed: {
            if(directionID == 0) {
                pageStack.pop()
            }

        }

    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
            Layout.fillWidth: true
            text: qsTr("Submitted Rate:")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
        }


        VerticalDivider
        {
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
        }

        Flickable{
            id: energyRateFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: energyRateFlickable.height
            contentWidth: app.width
            visible: erProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/3
            Layout.preferredWidth: app.width
            flickableDirection: Flickable.VerticalFlick

            Rectangle{
            Layout.preferredHeight: app.height/3
            Layout.fillWidth: true
            visible: erProxy.count === 0
            color: Material.background
                Text {
                    text: qsTr("There is no rate set up yet")
                    color: Material.foreground
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignLeft
                }
            }

            ColumnLayout{
                id: energyRateFlickableList
                Layout.preferredWidth: app.width
                Layout.fillHeight: true
                Repeater{
                    id: energyRateRepeater
                    Layout.preferredWidth: app.width
                    model: ThingsProxy {
                        id: erProxy
                        engine: _engine
                        shownInterfaces: ["connectable"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            iconName: "../images/energy.svg"
                            progressive: false
                            text: erProxy.get(index) ? erProxy.get(index).name : ""
                            onClicked: {
                            }
                        }
                    }
                }
            }

        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
        }

    }

        ColumnLayout {
            Layout.topMargin: Style.margins
            visible: false
            Label {
                Layout.fillWidth: true
                text: qsTr("Add Rate: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: energyRateComboBox
                Layout.preferredWidth: app.width - 2*Style.margins
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "connectable"
                    filterDisplayName: "Tibber"
                    includeProvidedInterfaces: true
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            visible: false
            Button {
                text: qsTr("cancel")
                Layout.preferredWidth: 200
                onClicked:
                    if(directionID == 0) {
                        pageStack.pop()
                    }
            }
            Button {
                id: addButton
                text: qsTr("add")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                visible: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRateFeedback.qml"), { hemsManager: hemsManager })
                }
                    //internalPageStack.push(creatingMethodDecider, {thingClassId: thingClassComboBox.currentValue})
            }

            Button {
                id: nextStepButton
                text: qsTr("Next step")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                Layout.preferredWidth: 200
                Layout.preferredHeight: addButton.height - 9
                Layout.topMargin: 5

                contentItem:Row{
                    Text{
                        id: nextStepButtonText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: nextStepButton.text
                        font: nextStepButton.font
                        opacity: enabled ? 1.0 : 0.3
                        color: Style.consolinnoHighlightForeground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image{
                        anchors.right : parent.right
                        anchors.verticalCenter:  parent.verticalCenter

                        sourceSize.width: 18
                        sourceSize.height: 18
                        source: "../images/next.svg"

                        layer{
                            enabled: true
                            effect: ColorOverlay{
                                color: Style.consolinnoHighlightForeground
                            }
                        }
                    }

                }

                background: Rectangle{
                    height: parent.height
                    width: parent.width
                    border.color: Material.background
                    color: energyRateRepeater.count > 0  ? Style.consolinnoHighlight : "grey"
                    radius: 4
                }

                Layout.alignment: Qt.AlignHCenter
                onClicked:{
                    if (energyRateRepeater.count >0){
                        root.done(true, false, false)
                    }
                }

            }
        }

        ColumnLayout {
            visible: true
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Loader {
                id: settingsLoader
                property bool showPage: false
                source: Qt.resolvedUrl("../optimization/DynamicElectricityRateSettings.qml")
            }
        }

    }
}
