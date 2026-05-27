pragma Singleton
import QtQuick
import "../../ui/"

StyleBase {
    id: root
    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: Configuration.iconColor
    property color consolinnoHighlight: "#189521"
    property color consolinnoHighlightForeground: Configuration.highlightForeground

    property real majorFontSize: 16
    property real screenMargins: 16

    property color buttonColor: "#87BD26"
    property color textfield: "#B6B6B6"
    mediumGray: textfield

    // Epex colors
    readonly property color epexMainLineColor: "#6CCB56"
    readonly property color epexAverageColor: "#C65B5A"
    readonly property color epexBarCurrentTime: "#189521"
    readonly property color epexBarPricingPast: "#3A3A3A"
    readonly property color epexBarPricingCurrentTime: "#B6B6B6"
    readonly property color epexBarPricingOutOfLimit: "#616161"
    readonly property color epexBarOutLine: "#303030"
    readonly property color epexBarMainLineColor: "#BDD786"
    readonly property color barSeriesDisabled: root.epexBarPricingPast

    // Switch
    readonly property color switchCircleColor: "#F4F6F4"
    readonly property color switchBagroundColor: "#80F4F6F4"
    readonly property color switchOnColor: buttonColor

    //DropDown
    readonly property color boxColor: "#D7D7D7"
    readonly property color borderColor: "transparent"
    readonly property color textColor: "#222222"
    readonly property color highlightColor: "#20222222"
    readonly property color currentItemColor: root.consolinnoMedium

    property color secondaryDark: "#B6B6B6"
    backgroundColor: "#303030"
    foregroundColor: "#F4F6F4"
    subTextColor: "#B6B6B6"

    tileOverlayIconColor: foregroundColor
    property color tabOverlayColor: foregroundColor
    property color tileOverlayTextColor: "#000000"

    accentColor: consolinnoMedium
    iconColor: "#F4F6F4"

    gray: "#9c9d9d"
    yellow: "#eec00a"
    blue: "#329eba"

    // Button
    readonly property color buttonTextColor: "#000000"
    readonly property color buttonTextColorNoBg: foregroundColor

    // Info colors
    readonly property color dangerAccent: "#FF5F79"
}
