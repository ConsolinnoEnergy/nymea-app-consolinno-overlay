import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0
import NymeaApp.Utils 1.0

import "../components"

Item {
    id: root

    // When floatingPoint is true, from/to/value/stepSize are in real (float) units.
    // Internally the SpinBox works with integers scaled by 10^decimals.
    property bool floatingPoint: false
    property int decimals: 2

    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1

    property alias acceptableInput: spinbox.acceptableInput
    property alias editable: spinbox.editable
    property alias spinbox: spinbox

    property alias labelText: label.text
    property alias infoUrl: label.push
    property alias helpText: helpLabel.text
    property alias unit: unitLabel.text
    property alias feedbackText: notification.text
    property alias showLabel: labelLayout.visible
    property bool compact: false

    readonly property int _scale: floatingPoint ? Math.pow(10, decimals) : 1

    signal valueModified(real value)

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    onValueChanged: {
        var scaled = Math.round(value * _scale);
        if (spinbox.value !== scaled) {
            spinbox.value = scaled;
        }
    }

    ColumnLayout{
        id: layout
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: 0

        ColumnLayout {
            id: labelLayout
            Layout.fillWidth: true
            spacing: Style.smallMargins
            opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity

            LabelWithInfo {
                id: label
                Layout.fillWidth: true
            }

            Text {
                id: helpLabel
                Layout.fillWidth: true
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
                text: ""
                visible: text !== ""
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.smallMargins

            SpinBox {
                id: spinbox
                Layout.fillWidth: true
                Layout.preferredWidth: root.compact ? 0 : -1
                Layout.leftMargin: -4
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                editable: true

                from: Math.round(root.from * root._scale)
                to: Math.round(root.to * root._scale)
                stepSize: Math.round(root.stepSize * root._scale)
                value: Math.round(root.value * root._scale)

                textFromValue: function(value, locale) {
                    if (!root.floatingPoint) {
                        return value.toString();
                    }
                    return NymeaUtils.floatToLocaleString(value / root._scale, root.decimals);
                }

                valueFromText: function(text, locale) {
                    if (!root.floatingPoint) {
                        return parseInt(text);
                    }
                    return Math.round(NymeaUtils.floatFromLocaleString(text) * root._scale);
                }

                validator: root.floatingPoint ? doubleValidator : intValidator

                onValueModified: {
                    root.value = spinbox.value / root._scale;
                    root.valueModified(root.value);
                }

                IntValidator {
                    id: intValidator
                    bottom: spinbox.from
                    top: spinbox.to
                }

                DoubleValidator {
                    id: doubleValidator
                    bottom: root.from
                    top: root.to
                    decimals: root.decimals
                    notation: DoubleValidator.StandardNotation
                    locale: Qt.locale().name
                }
            }

            Text {
                id: unitLabel
                Layout.fillWidth: root.compact
                Layout.preferredWidth: root.compact ? 0 : -1
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                text: ""
                visible: text !== ""
                opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity
            }
        }

        CoFieldNotification {
            id: notification
            Layout.fillWidth: true
            text: ""
            visible: root.enabled && text !== "" && !spinbox.acceptableInput
        }
    }
}
