import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

CoOverlay {
    id: root

    property alias description: descriptionLabel.text
    property int initialHours: 0
    property int initialMinutes: 0
    property bool quarterHours: true
    property bool includeMidnightHour: true;

    signal timeChosen(int hours, int minutes)

    onAccepted: {
        root.timeChosen(hoursPicker.currentValue, minutesPicker.currentValue)
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.largeMargins

        Label {
            id: descriptionLabel
            Layout.fillWidth: true
            font: Style.newParagraphFont
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.margins

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                spacing: Style.margins

                Label {
                    Layout.alignment: Qt.AlignCenter
                    font: Style.newExtraSmallFontBold
                    text: qsTr("h")
                }

                CoWheelPicker {
                    id: hoursPicker
                    visibleItemCount: 5
                    values: {
                        let result = []
                        for (let i = 0; i < 24; ++i) {
                            result.push(i)
                        }
                        if (root.includeMidnightHour) {
                            result.push(24)
                        }
                        return result
                    }

                    currentIndex: {
                        const ind = values.indexOf(root.initialHours)
                        return ind >= 0 ? ind : 0
                    }


                    onCurrentValueChanged: {
                        if (currentValue === 24) {
                            minutesPicker.selectValue(0)
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                spacing: Style.margins

                Label {
                    Layout.alignment: Qt.AlignCenter
                    font: Style.newExtraSmallFontBold
                    text: qsTr("min")
                }

                CoWheelPicker {
                    id: minutesPicker
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    visibleItemCount: 5
                    values: {
                        if (root.quarterHours) {
                            return [0, 15, 30, 45]
                        } else {
                            let result = []
                            for (let i = 0; i < 60; ++i) {
                                result.push(i)
                            }
                            return result
                        }
                    }
                    textForValue: function(value) {
                        if (value < 10) {
                            return "0" + value.toString()
                        } else {
                            return value.toString()
                        }
                    }

                    currentIndex: {
                        const ind = values.indexOf(root.initialMinutes)
                        return ind >= 0 ? ind : 0
                    }

                    onCurrentValueChanged: {
                        if (hoursPicker.currentValue === 24 && currentValue !== 0) {
                            Qt.callLater(() => selectValueImmediate(0))
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
