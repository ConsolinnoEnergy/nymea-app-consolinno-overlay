import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

CoOverlay {
    id: root

    property alias description: descriptionLabel.text

    signal timeChosen(int hours, int minutes)

    function setCurrentTime(hours, minutes) {
        hoursPicker.selectValueImmediate(hours);
        minutesPicker.selectValueImmediate(minutes);
    }

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
                    text: qsTr("Hours")
                }

                CoWheelPicker {
                    id: hoursPicker
                    visibleItemCount: 5
                    values: {
                        var result = []
                        for (let i = 0; i <= 24; ++i) {
                            result.push(i)
                        }
                        return result
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
                    text: qsTr("Minutes")
                }

                CoWheelPicker {
                    id: minutesPicker
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    visibleItemCount: 5
                    values: [0, 15, 30, 45]
                    textForValue: function(value) {
                        if (value === 0) {
                            return "00"
                        } else {
                            return value.toString()
                        }
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
