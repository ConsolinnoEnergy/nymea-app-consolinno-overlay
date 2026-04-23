// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Nymea
import NymeaApp.Utils
import "../components"

ItemDelegate {
    id: root

    property ParamType paramType: null
    property alias value: d.value
    property Param param: Param {
        id: d
        paramTypeId: paramType.id
        value: paramType.defaultValue
    }
    property bool writable: true
    property bool nameVisible: false // #TODO unused here (but in ParamDelegate) but needed to fulfill the interface of ParamDelegate
    property string placeholderText: ""

    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        color: "transparent"
    }

    contentItem: ColumnLayout {
        id: contentItemColumn
        anchors.fill: parent

        Loader {
            id: loader
            Layout.fillWidth: true
            sourceComponent: {
                console.debug("Loading CoParamDelegate");
                console.debug("Writable:", root.writable, "type:", root.paramType.type, "min:", root.paramType.minValue,
                              "max:", root.paramType.maxValue, "value:", root.param.value);

                if (!root.writable) {
                    return stringComponent;
                }

                switch (root.paramType.type.toLowerCase()) {
                case "bool":
                    return boolComponent;
                case "uint":
                case "int":
                    if (root.paramType.name == "colorTemperature") {
                        return null;
                    }
                case "double":
                    if (root.paramType.allowedValues.length > 0) {
                        return comboBoxComponent;
                    } else if (root.paramType.minValue !== undefined && root.paramType.maxValue !== undefined
                               && (root.paramType.maxValue - root.paramType.minValue <= 100)) {
                        return sliderComponent;
                    } else {
                        return spinnerComponent;
                    }
                case "string":
                case "qstring":
                    if (root.paramType.allowedValues.length > 0) {
                        return comboBoxComponent;
                    }
                    return textFieldComponent;
                case "color":
                case "qcolor":
                    return colorPreviewComponent;
                }
                console.warn("Param Delegate: Fallback to stringComponent", root.paramType.name, root.paramType.type);
                return stringComponent;
            }
        }
        Loader {
            Layout.fillWidth: true
            sourceComponent: {
                if (root.paramType.name == "colorTemperature") {
                    return colorTemperaturePickerComponent;
                }

                switch (root.paramType.type.toLowerCase()) {
                case "color":
                case "qcolor":
                    return colorPickerComponent
                }
                return null;
            }
        }

    }


    Component {
        id: stringComponent

        CoCard {
            Layout.fillWidth: true
            labelText: root.paramType.displayName
            interactive: false
            text: {
                let valueText = root.param.value;
                switch (root.paramType.type.toLowerCase()) {
                    case "int":
                        valueText = Math.round(root.param.value);
                        break;
                    case "double":
                        valueText = NymeaUtils.floatToLocaleString(root.param.value);
                        break;
                }
                const unitText = Types.toUiUnit(root.paramType.unit);
                return unitText === "" ?
                            valueText :
                            valueText + " " + unitText;
            }
        }
    }

    Component {
        id: boolComponent

        CoSwitch {
            Layout.fillWidth: true
            text: root.paramType.displayName
            checked: root.param.value === true

            Component.onCompleted: {
                if (root.param.value === undefined) {
                    root.param.value = checked;
                }
            }

            onClicked: {
                root.param.value = checked;
            }
        }
    }

    Component {
        id: sliderComponent

        CoSlider {
            Layout.fillWidth: true
            labelText: root.paramType.displayName
            from: root.paramType.minValue
            to: root.paramType.maxValue
            value: root.param.value
            property int decimals: root.paramType.type.toLocaleLowerCase() === "double" ? 1 : 0
            valueText: Types.toUiValue(root.param.value, root.paramType.unit).toFixed(slider.decimals) + Types.toUiUnit(root.paramType.unit)

            Component.onCompleted: {
                if (root.param.value === undefined) {
                    if (root.paramType.defaultValue !== undefined) {
                        root.param.value = root.paramType.defaultValue
                    } else {
                        root.param.value = root.paramType.minValue
                    }
                }
            }

            stepSize: {
                var ret = 1
                for (var i = 0; i < decimals; i++) {
                    ret /= 10;
                }
                return ret;
            }

            onMoved: {
                var newValue
                switch (root.paramType.type.toLowerCase()) {
                case "int":
                    newValue = Math.round(value)
                    break;
                default:
                    newValue = Math.round(value * 10) / 10
                }
                root.param.value = newValue;
            }
        }
    }

    Component {
        id: spinnerComponent

        CoInputStepper {
            labelText: root.paramType.displayName
            unit: Types.toUiUnit(root.paramType.unit)
            floatingPoint: root.paramType.type.toLowerCase() === "double"
            value: root.param.value !== undefined ? root.param.value : 0
            from: root.paramType.minValue !== undefined
                  ? root.paramType.minValue
                  : root.paramType.type.toLowerCase() === "uint"
                    ? 0
                    : -1000000
            to: root.paramType.maxValue !== undefined
                ? root.paramType.maxValue
                : 1000000
            editable: true
            compact: true

            Component.onCompleted: {
                if (root.value === undefined) {
                    root.value = value
                }
            }

            onValueModified: (value) => root.param.value = value
        }
    }

    Component {
        id: textFieldComponent

        CoInputField {
            labelText: root.paramType.displayName
            unit: Types.toUiUnit(root.paramType.unit)
            text: root.param.value !== undefined
                  ? root.param.value
                  : root.paramType.defaultValue
                    ? root.paramType.defaultValue
                    : ""
            textField.placeholderText: root.placeholderText

            textField.onEditingFinished: root.param.value = text

            Component.onCompleted: {
                if (root.param.value === undefined) {
                    root.param.value = text;
                }
            }
        }
    }

    Component {
        id: comboBoxComponent

        CoComboBox {
            labelText: root.paramType.displayName
            model: root.paramType.allowedValues
            comboBox.displayText: currentText + (root.paramType.unit != Types.UnitNone ? " " + Types.toUiUnit(root.paramType.unit) : "")
            currentIndex: root.paramType.allowedValues.indexOf(root.param.value !== undefined ? root.param.value : root.paramType.defaultValue)
            comboBox.delegate: ItemDelegate {
                width: comboBox.width
                text: Types.toUiValue(modelData, root.paramType.unit) + (root.paramType.unit != Types.UnitNone ? " " + Types.toUiUnit(root.paramType.unit) : "")
                highlighted: comboBox.highlightedIndex === index
            }
            comboBox.onActivated: (index) => {
                root.param.value = root.paramType.allowedValues[index]
            }
            Component.onCompleted: {
                if (root.value === undefined) {
                    root.value = model[0]
                }
            }
        }
    }

    Component {
        id: colorPickerComponent
        ColumnLayout {
            spacing: Style.margins
            Label {
                text: root.paramType.displayName
                Layout.fillWidth: true
            }
            ColorPickerPre510 {
                id: colorPicker
                implicitHeight: 200

                Binding {
                    target: colorPicker
                    property: "color"
                    value: root.param.value
                    when: !colorPicker.pressed
                }

                onColorChanged: {
                    root.param.value = color;
                }

                touchDelegate: Rectangle {
                    height: 15
                    width: height
                    radius: height / 2

                    Rectangle {
                        color: colorPicker.hovered || colorPicker.pressed ? "#11000000" : "transparent"
                        anchors.centerIn: parent
                        height: 30
                        width: height
                        radius: width / 2
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }
    }

    Component {
        id: colorTemperaturePickerComponent
        ColumnLayout {
            spacing: Style.margins
            Label {
                text: root.paramType.displayName
                Layout.fillWidth: true
            }
            ColorPickerCt {
                id: colorPickerCt
                Layout.fillWidth: true
                implicitHeight: 50
                minCt: root.paramType.minValue
                maxCt: root.paramType.maxValue
                ct: root.param.value !== undefined
                    ? root.param.value
                    : root.paramType.defaultValue
                      ? root.paramType.defaultValue
                      : root.paramType.minValue

                onCtChanged: {
                    root.param.value = ct
                }

                touchDelegate: Rectangle {
                    height: colorPickerCt.height
                    width: 5
                    color: Style.accentColor
                }
            }
        }
    }

    Component {
        id: colorPreviewComponent
        RowLayout {
            spacing: Style.margins
            Label {
                text: root.paramType.displayName
                Layout.fillWidth: true
            }
            Rectangle {
                implicitHeight: app.mediumFont
                implicitWidth: implicitHeight
                color: root.param.value
                radius: width / 4
            }
        }
    }
}
