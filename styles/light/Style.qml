pragma Singleton
import QtQuick 2.0
import "../../ui/"

StyleBase {

    property color consolinnoExtraDark: "#193c4d"
    property color consolinnoDark: "#0450c9"
    property color consolinnoMedium: "#639df7"
    property color consolinnoLight: "#75a9fa"
    property color consolinnoExtraLight: "#75a9fa"
    property color consolinnoHighlight: "#75a9fa"
    property color consolinnoHighlightForeground: "white"

    property real majorFontSize: 16
    property real screenMargins: 16

    property color buttonColor: "#75a9fa"
    property real buttonFontSize: 16
    property real buttonTopPading: 16
    property real buttonLeftPadding: 32

    backgroundColor: "white"
    foregroundColor: consolinnoExtraDark

//    tileBackgroundColor: "white"
//    tileOverlayColor: "#DDE8B4"
    tileOverlayIconColor: consolinnoDark

    accentColor: consolinnoMedium
    iconColor: consolinnoExtraDark

    gray: "#9c9d9d"
    darkGray: "#717171"
    yellow: "#eec00a"
    blue: "#329eba"

    fontFamily: Configuration.fontFamily
    //fontFamily: ""

}
