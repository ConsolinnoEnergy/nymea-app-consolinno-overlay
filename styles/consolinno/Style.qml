pragma Singleton
import QtQuick 2.0
import "../../ui"

StyleBase {

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: "#87BD26"
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#BDD758"

    backgroundColor: "white"
    foregroundColor: consolinnoExtraDark

    headerBackgroundColor: backgroundColor
    headerForegroundColor: foregroundColor

//    tileBackgroundColor: "white"
//    tileOverlayColor: "#DDE8B4"
    tileOverlayIconColor: consolinnoDark

    accentColor: consolinnoMedium
    iconColor: consolinnoExtraDark
}
