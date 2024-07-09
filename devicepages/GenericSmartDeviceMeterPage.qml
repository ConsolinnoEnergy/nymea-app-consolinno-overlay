import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"

GenericConfigPage {
    id: root

    property Thing thing: null
    readonly property ThingClass thingClass: thing.thingClass

    readonly property bool isEnergyMeter: root.thing && root.thing.thingClass.interfaces.indexOf("energymeter") >= 0
    readonly property bool isConsumer: root.thing && root.thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0
    readonly property bool isProducer: root.thing && root.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
    readonly property bool isBattery: root.thing && root.thingClass.interfaces.indexOf("energystorage") >= 0

    readonly property State currentPowerState: root.thing.stateByName("currentPower")

    // meters, producers, consumers
    readonly property State totalEnergyConsumedState: isEnergyMeter || isConsumer ? root.thing.stateByName("totalEnergyConsumed") : null
    readonly property StateType totalEnergyConsumedStateType: isEnergyMeter || isConsumer ? root.thing.thingClass.stateTypes.findByName("totalEnergyConsumed") : null
    readonly property State totalEnergyProducedState: isEnergyMeter || isProducer ? root.thing.stateByName("totalEnergyProduced") : null
    readonly property StateType totalEnergyProducedStateType: isEnergyMeter || isProducer ? root.thing.thingClass.stateTypes.findByName("totalEnergyProduced") : null

    // Battery related states
    readonly property State batteryLevelState: isBattery ? root.thing.stateByName("batteryLevel") : null
    readonly property State batteryCriticalState: isBattery ? root.thing.stateByName("batteryCritical") : null
    readonly property State chargingState: isBattery ? root.thing.stateByName("chargingState") : null
    readonly property State capacityState: isBattery ? root.thing.stateByName("capacity") : null

    property bool isProduction: currentPowerState.value < 0
    property bool isConsumption: currentPowerState.value > 0
    property double absValue: Math.abs(currentPowerState.value)
    property double cleanVale: (absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1)
    property string unit: absValue > 1000 ? "kW" : "W"

    readonly property bool isCharging: root.chargingState && root.chargingState.value === "charging"
    readonly property bool isDischarging: root.chargingState && root.chargingState.value === "discharging"

    property bool isRootmeter: false
    property bool isNotify: false

    title: root.thing.name

    content: [
        Item {
            anchors.fill: parent

            ThingInfoPane {
                id: infoPane
                anchors { left: parent.left; top: parent.top; right: parent.right }
                thing: root.thing
            }

            Item {
                id: notificationsContainer
                anchors.top: parent.top
                height: root.isRootmeter ? (infoElement.implicitHeight) : 0
                width: parent.width
                visible: root.isRootmeter

                ColumnLayout {
                    id: infoElement
                    width: root.width
                    anchors.top: parent.top

                    property var states: {
                        "limited": {
                            "header": qsTr("Grid-Supportive Control"),
                            "content": qsTr("The consumption is <b>temporarily reduced</b> to §14a minimum."),
                            "color": "warning"
                        },
                        "blocked": {
                            "header": qsTr("Grid-Supportive Control"),
                            "content": qsTr("The consumption is <b>temporarily blocked</b> by the network operator."),
                            "color": "danger"
                        }
                    }

                    property var infoColors: {
                        "warning": "#fc9d03",
                        "danger": "#eb4034"
                    }

                    property string infoColor: "#fc9d03"
                    property string currentState: isNotify && isRootmeter ? "limited" : isNotify && isRootmeter ? "blocked" : ""

                        Rectangle {
                            width: infoElement.width - 40
                            Layout.alignment: Qt.AlignHCenter
                            radius: 10
                            color: "#faf9f5"
                            border.width: 1
                            border.color: infoElement.infoColors[infoElement.states[infoElement.currentState].color]
                            implicitHeight: alertContainer.implicitHeight + 20

                            ColumnLayout {
                                id: alertContainer
                                anchors.fill: parent
                                spacing: 1

                                Item {
                                    Layout.preferredHeight: 10
                                }


                                RowLayout {
                                    width: parent.width
                                    spacing: 5

                                    Item {
                                        Layout.preferredWidth: 10
                                    }

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10  // Makes the rectangle a circle
                                        color: "white"
                                        border.color: infoElement.infoColors[infoElement.states[infoElement.currentState].color]
                                        border.width: 2
                                        RowLayout.alignment: Qt.AlignVCenter

                                        Label {
                                            text: "!"
                                            anchors.centerIn: parent
                                            font.bold: true
                                            color: infoElement.infoColors[infoElement.states[infoElement.currentState].color]
                                        }
                                    }

                                    Label {
                                        font.pixelSize: 16
                                        text: infoElement.states[infoElement.currentState].header
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: parent.width - 20
                                    }
                                }
                                Label {
                                    font.pixelSize: 16
                                    text: infoElement.states[infoElement.currentState].content
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width - 20
                                    leftPadding: 40
                                }

                                Item {
                                    Layout.preferredHeight: 10
                                }
                            }
                        }
                }
            }

            CircleBackground {
                id: background
                width: parent.width / 1.5
                height: parent.height / 2
                iconSource: ""
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: notificationsContainer.bottom
                anchors.topMargin: 16

                onColor: {
                    if (root.isBattery) {
                        if (root.isCharging) {
                            return Style.purple
                        }
                        if (root.isDischarging) {
                            return Style.orange
                        }
                        return Style.green
                    }
                    if (root.isEnergyMeter)
                        return root.currentPowerState.value < 0 ? Style.green : Style.blue
                }

                Behavior on onColor { ColorAnimation { duration: Style.fastAnimationDuration } }

                Rectangle {
                    id: mask
                    anchors.centerIn: parent
                    width: background.contentItem.width
                    height: background.contentItem.height
                    radius: width / 2
                    visible: false
                }

                Item {
                    id: juice
                    anchors.fill: parent

                    Rectangle {
                        anchors.centerIn: parent
                        width: background.contentItem.width
                        height: background.contentItem.height
                        property real progress: root.batteryLevelState ? root.batteryLevelState.value  / 100 : 0
                        anchors.verticalCenterOffset: height * (1 - progress)
                        color: background.onColor
                        visible: root.isBattery
                    }

                    RadialGradient {
                        id: gradient
                        anchors.centerIn: parent
                        width: background.contentItem.width
                        height: background.contentItem.height
                        property real progress: Math.abs(root.currentPowerState.value) / 10000
                        visible: root.currentPowerState.value !== 0

                        Behavior on gradientRatio { NumberAnimation { duration: Style.sleepyAnimationDuration; easing.type: Easing.InOutQuad } }
                        property real gradientRatio: (1 - progress) * 0.1
                        gradient: Gradient{
                            GradientStop { position: .399 + gradient.gradientRatio; color: "transparent" }
                            GradientStop { position: .5; color: background.onColor }
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent

                        Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            font: Style.largeFont
                            text: "%1 %2".arg(root.cleanVale).arg(root.unit)
                        }

                        Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: {
                                if (root.chargingState) {
                                    switch (root.chargingState.value) {
                                    case "idle":
                                        return qsTr("Idle")
                                    case "charging":
                                        return qsTr("Charging")
                                    case "discharging":
                                        return qsTr("Discharging")
                                    }
                                }
                                if (root.isProducer) {
                                    return qsTr("Producing")
                                }
                                if (root.isConsumer) {
                                    return qsTr("Consuming")
                                }

                                return root.currentPowerState.value < 0 ? qsTr("Returning") : qsTr("Obtaining")
                            }
                            font: Style.smallFont
                        }


                        Label {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            font: Style.bigFont
                            visible: batteryLevelState
                            text: "%1 %".arg(batteryLevelState ? batteryLevelState.value : "")
                        }
                    }

                }

                OpacityMask {
                    anchors.centerIn: parent
                    width: background.contentItem.width
                    height: background.contentItem.height
                    source: ShaderEffectSource {
                        sourceItem: juice
                        hideSource: true
                        sourceRect: Qt.rect(background.contentItem.x, background.contentItem.y, background.contentItem.width, background.contentItem.height)
                    }
                    maskSource: mask
                }
            }

            Item {
                width: parent.width
                height: infoText.height
                anchors.top: background.bottom

                Label {
                    id: infoText

                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.RichText
                    padding: 16;
                    font.pixelSize: 16

                    property double availableWh: isBattery ? root.capacityState.value * 1000 * root.batteryLevelState.value / 100 : 0
                    property double remainingWh: isCharging ? root.capacityState.value * 1000 - availableWh : availableWh
                    property double remainingHours: isBattery ? remainingWh / Math.abs(root.currentPowerState.value) : 0
                    property date endTime: isBattery ? new Date(new Date().getTime() + remainingHours * 60 * 60 * 1000) : new Date()
                    property int n: Math.round(remainingHours)

                    text: root.isConsumer
                          ? qsTr("Total Consumption: %1 kWh").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + root.totalEnergyConsumedState.value.toFixed(2) + "</span>")
                          : root.isProducer
                            ? qsTr("Total Production: %1 kWh").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + root.totalEnergyProducedState.value.toFixed(2) + "</span>")
                            : root.isEnergyMeter
                              ? qsTr("Total Acquisition: %1 kWh").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + root.totalEnergyConsumedState.value.toFixed(2) + "</span>") + "<br>" + qsTr("Total Return: %1 kWh").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + root.totalEnergyProducedState.value.toFixed(2) + "</span>")
                              : root.isBattery && isCharging
                                ? qsTr("At the current rate, the battery will be fully charged at %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + endTime.toLocaleTimeString(Locale.ShortFormat) + "</span>")
                                : root.isBattery && isDischarging
                                  ? qsTr("At the current rate, the battery will last until %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + endTime.toLocaleTimeString(Locale.ShortFormat) + "</span>")
                                  : ""
                }
            }
        }
    ]
}
