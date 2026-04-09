import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property int directionID: 0

    // #TODO needed here? i.e. should this screen be included in the setup assistant?
    signal done(bool skip, bool abort, bool back)

    header: NymeaHeader {
        text: qsTr("PV Device Prioritization") // #TODO wording
        backButtonVisible: true
        onBackPressed:{
            if (directionID == 0) {
                pageStack.pop();
            } else {
                root.done(false, false, true);
            }
        }
    }

    // QtObject {
    //     id: d
    //     property int pendingCallId: -1
    // }

    // Connections {
    //     target: hemsManager
    //     onHousholdPhaseLimitChanged: {
    //         configuredPhaseLimit = housholdPhaseLimit;
    //     }

    //     onSetHousholdPhaseLimitReply: {
    //         if (commandId == d.pendingCallId) {
    //             d.pendingCallId = -1;
    //             var props = {};
    //             switch (error) {
    //             case "HemsErrorNoError":
    //                 pageStack.pop();
    //                 return;
    //             case "HemsErrorInvalidPhaseLimit":
    //                 props.text = qsTr("Invalid phase limit.");
    //                 break;
    //             default:
    //                 props.errorCode = error;
    //             }
    //             var comp = Qt.createComponent("../components/ErrorDialog.qml");
    //             var popup = comp.createObject(app, props);
    //             popup.open();
    //         }
    //     }
    // }

    // Component.onCompleted: {
    //     phaseLimit = hemsManager.housholdPhaseLimit;
    //     configuredPhaseLimit = hemsManager.housholdPhaseLimit;
    //     const comboIndex = currentCombo.comboBox.indexOfValue(configuredPhaseLimit);
    //     if (comboIndex !== -1) {
    //         currentCombo.comboBox.currentIndex = comboIndex;
    //         currentInput.textField.text = "16";
    //     } else {
    //         // Last item is "user defined" current.
    //         currentCombo.comboBox.currentIndex = currentCombo.comboBox.count -1;
    //         currentInput.textField.text = configuredPhaseLimit.toString();
    //     }
    // }

    ListModel {
        id: blackoutProtectionModel
        ListElement { name: qsTr("25 A"); current: 25 }
        ListElement { name: qsTr("35 A"); current: 35 }
        ListElement { name: qsTr("40 A"); current: 40 }
        ListElement { name: qsTr("50 A"); current: 50 }
        ListElement { name: qsTr("63 A"); current: 63 }
        ListElement { name: qsTr("User defined"); current: 0 }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.smallMargins
            headerText: qsTr("Device Prioritization") // #TODO wording

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins
                spacing: Style.smallMargins

                Text {
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font: Style.newParagraphFont
                    color: Style.colors.typography_Basic_Default
                    // #TODO wording
                    text: qsTr("The following devices are configured for surplus PV power. Sort them by priority using drag and drop. The battery automatically moves to the last position when its SoC reaches XY%.")
                }

                ListView {
                    id: priorityListView
                    Layout.fillWidth: true
                    height: contentHeight
                    model: blackoutProtectionModel // #TODO
                    clip: true

                    property bool dragging: draggingIndex >= 0
                    property int draggingIndex: -1

                    moveDisplaced: Transition { NumberAnimation { properties: "y" } }

                    delegate: CoSortableCard {
                        width: priorityListView.width
                        text: model.name
                        iconLeft: Qt.resolvedUrl("qrc:/icons/interests.svg")
                        visible: index !== priorityListView.draggingIndex
                    }

                    MouseArea {
                        id: dndArea
                        anchors.fill: parent
                        propagateComposedEvents: true
                        preventStealing: priorityListView.dragging
                        property int dragOffset: 0

                        onPressed: (mouse) => {
                            var mouseYInList = priorityListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                            var item = priorityListView.itemAt(mouseX, mouseYInList);
                            if (!item || mouseX < item.dragHandleStartX) {
                                mouse.accepted = false;
                                return;
                            }
                            priorityListView.draggingIndex = priorityListView.indexAt(mouseX, mouseYInList);
                            dndItem.text = blackoutProtectionModel.get(priorityListView.draggingIndex).name;
                            dndArea.dragOffset = priorityListView.mapToItem(item, mouseX, mouseY).y;
                        }

                        onMouseYChanged: {
                            if (!priorityListView.dragging) { return; }
                            var mouseYInList = priorityListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                            var indexUnderMouse = priorityListView.indexAt(mouseX, mouseYInList - dndArea.dragOffset / 2);
                            if (indexUnderMouse < 0) { return; }
                            indexUnderMouse = Math.min(Math.max(0, indexUnderMouse), priorityListView.count - 1);
                            if (priorityListView.draggingIndex !== indexUnderMouse) {
                                blackoutProtectionModel.move(priorityListView.draggingIndex, indexUnderMouse, 1);
                                priorityListView.draggingIndex = indexUnderMouse;
                            }
                        }

                        onReleased: {
                            priorityListView.draggingIndex = -1;
                        }
                    }

                    CoSortableCard {
                        id: dndItem
                        visible: priorityListView.dragging
                        dragging: true
                        y: dndArea.mouseY - dndArea.dragOffset
                        width: priorityListView.width
                        iconLeft: Qt.resolvedUrl("qrc:/icons/interests.svg")
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            // #TODO
            // enabled: {
            //     if (phaseLimit === configuredPhaseLimit) {
            //         return false;
            //     }
            //     if (currentCombo.comboBox.currentValue === 0 &&
            //             !currentInput.textField.acceptableInput) {
            //         return false;
            //     }
            //     return true;
            // }
            text: qsTr("Save")

            onClicked: {
                // #TODO
                // if (directionID === 0) {
                //     d.pendingCallId = hemsManager.setHousholdPhaseLimit(root.phaseLimit);
                // } else if (directionID === 1) {
                //     hemsManager.setHousholdPhaseLimit(root.phaseLimit);
                //     root.done(false, false, false);
                // }
            }
        }
    }
}
