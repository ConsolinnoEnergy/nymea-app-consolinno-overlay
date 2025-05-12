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

    backgroundColor: "white"
    foregroundColor: consolinnoExtraDark

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
