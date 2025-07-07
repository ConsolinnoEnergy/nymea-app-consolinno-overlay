import QtQuick 2.12
import QtQuick.Controls 2.15
import Nymea 1.0
import QtQuick.Controls.Material 2.1
import QtQml 2.15
import QtQuick.Layouts 1.3

import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property HemsManager hemsManager
    property Thing thing
    readonly property State operationState: root.thing.stateByName("operationState")
    readonly property State selectedProgramState: root.thing.stateByName("selectedProgram")
    readonly property State progressState: root.thing.stateByName("progress")
    readonly property State endTimeState: {
        let date = new Date(root.thing.stateByName("endTime").value * 1000);
        return date.toLocaleTimeString()
    }

    title: root.thing.name
    headerOptionsVisible: false

    content: [

        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight
            clip: false

            ColumnLayout{
                id: columnLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins

                Repeater {

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 5

                    model: [
                         {Id: "operatingMode", name: qsTr("Operating mode"), value: translateNymeaOperationValues(operationState.value), unit: "", component: stringValues,},
                         {Id: "progress", name: qsTr("Progress"), value: progressState.value, unit: "%", component: stringValues,},
                         {Id: "programm", name: qsTr("Programm"), value: selectedProgramState.value, unit: "", component: stringValues,},
                         {Id: "endingTime", name: qsTr("Ending Time"), value: endTimeState, unit: "", component: stringValues,},
                    ]

                    delegate: ConsolinnoItemDelegate {
                        id: optimizerMainParams
                        Layout.fillWidth: true
                        contentItem: ColumnLayout
                        {

                            RowLayout{

                                Loader
                                {
                                    id: optimizationParams
                                    Layout.fillWidth: true
                                    Binding{
                                        target: optimizationParams.item
                                        property: "delegateID"
                                        value: modelData.Id
                                    }

                                    Binding{
                                        target: optimizationParams.item
                                        property: "delegateName"
                                        value: modelData.name
                                    }

                                    Binding{
                                        target: optimizationParams.item
                                        property: "delegateValue"
                                        value: modelData.value
                                    }

                                    Binding{
                                        target: optimizationParams.item
                                        property: "delegateUnit"
                                        value: modelData.unit
                                    }

                                    sourceComponent:
                                    {
                                        return modelData.component
                                    }
                                }
                            }
                        }
                    }

                    function translateNymeaOperationValues(value){
                        switch(value)
                        {
                            case"Off":
                            {
                                return qsTr("Off")
                            }
                            case "Run":
                            {
                                return qsTr("Run")
                            }
                            case "Idle":
                            {
                                return qsTr("Idle")
                            }
                            case "Finished":
                            {
                                return qsTr("Finished")
                            }
                        }
                    }
                }

                Component{
                    id: stringValues

                    RowLayout {
                        property string delegateID: ""
                        property var delegateName
                        property var delegateValue
                        property var delegateUnit

                        Label{
                            id: singleInput
                            text: delegateName
                            Layout.fillWidth: true
                        }

                        Label{
                            id: singleValue
                            text: delegateValue + delegateUnit
                        }
                    }
                }
            }
        }

    ]
}
