pragma Singleton
import QtQuick 2.0
import "../../ui/"

StyleBase {

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: Configuration.iconColor
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#BDD758"
    property color consolinnoHighlight: "#189521"
    property color consolinnoHighlightForeground: Configuration.highlightForeground

    property real majorFontSize: 16
    property real screenMargins: 16

    property color buttonColor: "#87BD26"
    property real buttonFontSize: 16
    property real buttonTopPading: 16
    property real buttonLeftPadding: 32

    property color textfield: "#B6B6B6"

    // Epex colors
    readonly property color epexColor: "#E056F5"
    readonly property color epexMainLineColor: "#6CCB56"
    readonly property color epexAverageColor: "#C65B5A"
    readonly property color epexBarCurrentTime: "#189521"
    readonly property color epexBarPricingPast: "#3A3A3A"
    readonly property color epexBarPricingCurrentTime: "#B6B6B6"
    readonly property color epexBarPricingOutOfLimit: "#616161"
    readonly property color epexBarOutLine: "#303030"
    readonly property color epexBarMainLineColor: "#BDD786"

    backgroundColor: "#303030"
    foregroundColor: "#F4F6F4"
    subTextColor: "#B6B6B6"

    property color legendTileHeaderBgColor: "#80000000"

    tileOverlayIconColor: foregroundColor
    property color tabOverlayColor: foregroundColor
    property color tileOverlayTextColor: "#000000"

    accentColor: consolinnoMedium
    iconColor: "#F4F6F4"

    gray: "#9c9d9d"
    darkGray: "#717171"
    yellow: "#eec00a"
    blue: "#329eba"

    fontFamily: Configuration.fontFamily

    // Button
    readonly property color secondButtonColor: "#189521"
    readonly property color buttonTextColor: "#000000"

    // Info colors
    readonly property color dangerBackground: "#4D020E"
    readonly property color dangerAccent: "#FF5F79"

    readonly property color warningBackground: "#431E05"
    readonly property color warningAccent: "#FDC812"

    readonly property color successBackground: "#062D0A"
    readonly property color successAccent: "#26C131"

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
    readonly property color mainTimeCircle: "#5A5A5A"
    readonly property color mainTimeCircleDivider: "#303030"
    readonly property color mainCircleTimeColor: "#D3D3D3"

    readonly property color mainTimeNow: "#D3D3D3"

    readonly property color mainInnerCicleFirst: "#5A5A5A"
    readonly property color mainInnerCicleSecond: "#5A5A5A"
    readonly property color mainInnerCicleText: "#D3D3D3"
}
