
// #TODO copyright notice

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import Qt.labs.settings 1.1
import QtGraphicalEffects 1.15

import "../components"
import "../delegates"

MainViewBase {
    id: root

    headerButtons: []

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    HemsManager {
        id: hemsManager
        engine: _engine
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        Rectangle {
            id: background
            anchors.fill: parent
            color: "#FFFFFF" // #TODO color from new style

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop{ position: 0.0; color: "#80BDD786" } // #TODO color from new style
                    GradientStop{ position: 1.0; color: "#8083BC32" } // #TODO color from new style
                }
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 16 // #TODO use value from new style


            ColumnLayout {
                anchors.fill: parent

                CoFrostyCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    headerText: "Header"
                    ColumnLayout {
                        id: col
                        anchors.fill: parent
                        spacing: 16 // #TODO use value from new style

                        CoInfoCard {
                            Layout.fillWidth: true

                            text: "Inverter"
                            icon: Qt.resolvedUrl("qrc:/icons/heatpump.svg")
                            value: "700 W"
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            CoInfoCard {
                                Layout.fillWidth: true

                                text: "Inverter"
                                icon: Qt.resolvedUrl("qrc:/icons/heatpump.svg")
                                value: "700 W"
                                compactLayout: true
                            }

                            CoInfoCard {
                                Layout.fillWidth: true

                                text: "Inverter"
                                icon: Qt.resolvedUrl("qrc:/icons/heatpump.svg")
                                value: "700 W"
                                compactLayout: true
                            }
                        }
                    }
                }

                Rectangle {
                    id: spacer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    border.color: "red"
                    border.width: 1
                }
            }
        }
    }
}
