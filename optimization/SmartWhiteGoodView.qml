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
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(
                                                     thing.id)

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
                anchors.rightMargin: app.margins

                Repeater {

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 5

                    model: [ /* translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null) */
                         {Id: "operatingMode", name: qsTr("Operating mode"), value: translateNymeaHeatpumpValues("Run"), unit: "", component: stringValues,},
                         {Id: "progress", name: qsTr("Progress"), value: "50", unit: "%", component: stringValues,},
                         {Id: "programm", name: qsTr("Programm"), value: "ECO - 30", unit: "", component: stringValues,},
                         {Id: "endingTime", name: qsTr("Ending Time"), value: "13:40", unit: "", component: stringValues,},
                    ]

                    delegate: ItemDelegate {
                        id: optimizerMainParams
                        Layout.leftMargin: app.margins
                        Layout.fillWidth: true
                        contentItem: ColumnLayout
                        {
                            Layout.fillWidth: true

                            RowLayout{
                                Layout.fillWidth: true

                                Loader
                                {
                                    id: optimizationParams

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

                                    Layout.fillWidth: true
                                    sourceComponent:
                                    {
                                        return modelData.component
                                    }
                                }
                            }
                        }
                    }

                    function translateNymeaHeatpumpValues(something){
                        switch(something)
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
                            //property double numberValue: Number(delegateValue)

                            text: delegateValue + delegateUnit
                        }
                    }
                }
            }
        }

    ]
}
