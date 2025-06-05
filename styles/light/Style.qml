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

    tileOverlayIconColor: consolinnoDark

    accentColor: consolinnoMedium
    iconColor: consolinnoExtraDark

    gray: "#9c9d9d"
    darkGray: "#717171"
    yellow: "#eec00a"
    blue: "#329eba"

    fontFamily: Configuration.fontFamily

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


}
