pragma Singleton
import QtQuick
import "../../ui/"

StyleBase {
    id: root

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: Configuration.iconColor
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#BDD758"
    property color consolinnoHighlight: "#189521"
    property color consolinnoHighlightForeground: Configuration.highlightForeground
    property color legendTileIconColor: "#222222"

    // Epex colors
    readonly property color epexColor: "#E056F5"
    readonly property color epexMainLineColor: "#6CCB56"
    readonly property color epexAverageColor: "#C65B5A"
    readonly property color epexCurrentTime: "#2C723C"

    readonly property color epexBarCurrentTime: "#189521"
    readonly property color epexBarPricingPast: "#F4F6F4"
    readonly property color epexBarPricingCurrentTime: "#767676"
    readonly property color epexBarPricingOutOfLimit: "#E0E0E0"
    readonly property color epexBarOutLine: "#FFFFFF"
    readonly property color epexBarMainLineColor: "#BDD786"
    readonly property color barSeriesDisabled: root.epexBarPricingPast

    //Dropdown
    readonly property color boxColor: "#FFFFFF"
    readonly property color borderColor: "transparent"
    readonly property color textColor: root.consolinnoDark
    readonly property color highlightColor: "#20222222"
    readonly property color currentItemColor: root.consolinnoMedium

    // Switch
    readonly property color switchCircleColor: "#F4F6F4"
    readonly property color switchBagroundColor: "#80222222"
    readonly property color switchOnColor: buttonColor

    property color secondaryDark: "#767676"
    property real majorFontSize: 16
    property real screenMargins: 16

    property color buttonColor: "#87BD26"
    property real buttonFontSize: 16
    property real buttonTopPading: 16
    property real buttonLeftPadding: 32
    property color textfield: "#767676"

    // Avoid Zero Compensation Info + Dialog
    property color marketPriceColor: "#E056F5"
    property color pvProductionColor: "#FCE487"
    property color socWithoutControllerColor: "#B6B6B6"
    property color socWithControllerColor: "#BDD786"
    property color xAxisColor: "#194D25"
    property color yAxisColor: "#194D25"
    property color arrowColor: "#194D25"

    backgroundColor: "white"
    foregroundColor: consolinnoExtraDark
    subTextColor: "#767676"

    property color legendTileHeaderBgColor: "#3B000000"

    tileOverlayIconColor: consolinnoDark
    property color tabOverlayColor: consolinnoDark
    property color tileOverlayTextColor: "#ffffff"

    accentColor: consolinnoMedium
    iconColor: consolinnoExtraDark

    gray: "#9c9d9d"
    darkGray: "#717171"
    yellow: "#eec00a"
    blue: "#329eba"

    fontFamily: Configuration.fontFamily

    // Button
    readonly property color secondButtonColor: "#189521"
    readonly property color buttonTextColor: "#000000"
    readonly property color buttonTextColorNoBg: buttonTextColor

    // Info colors
    readonly property color dangerBackground: "#FFC3CD"
    readonly property color dangerAccent: "#AA0A24"

    readonly property color warningBackground: "#FFEE89"
    readonly property color warningAccent: "#864A0D"

    readonly property color successBackground: "#BDF5BF"
    readonly property color successAccent: "#18631E"

    //font size and font family
    readonly property font extraSmallFont: Qt.font({
        family: Configuration.fontFamily,
        pixelSize: 10
    })
    readonly property font font: Qt.font({
        family: Configuration.fontFamily,
        pixelSize: 16
    })
    readonly property font bigFont: Qt.font({
        family: Configuration.fontFamily,
        pixelSize: 20
    })
    readonly property font largeFont: Qt.font({
        family: Configuration.fontFamily,
        pixelSize: 32
    })
    readonly property font hugeFont: Qt.font({
        family: Configuration.fontFamily,
        pixelSize: 46
    })

    //MainMenuCirlce
    readonly property color mainTimeCircle: "#D3D3D3"
    readonly property color mainTimeCircleDivider: "#ffffff"
    readonly property color mainCircleTimeColor: "#5A5A5A"

    readonly property color mainTimeNow: "#808080"

    readonly property color mainInnerCicleFirst: "#b6b6b6"
    readonly property color mainInnerCicleSecond: "#b6b6b6"
    readonly property color mainInnerCicleText: "#303030"
}
