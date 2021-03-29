pragma Singleton
import QtQuick 2.0
import "../../ui"

StyleBase {

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: "#87BD26"
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#BDD758"

    backgroundColor: "#393a39"
    foregroundColor: "white"

    headerBackgroundColor: backgroundColor
    headerForegroundColor: foregroundColor

//    tileBackgroundColor:
//    tileOverlayColor: "#DDE8B4"
    tileOverlayIconColor: foregroundColor

    accentColor: consolinnoMedium
    iconColor: consolinnoLight
}
