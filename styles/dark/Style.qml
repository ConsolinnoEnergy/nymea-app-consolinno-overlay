pragma Singleton
import QtQuick 2.0
import "../../ui"

StyleBase {

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: "#87BD26"
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#DDE8B4"
    property color consolinnoHighlight: "#006400"

    backgroundColor: "#414141"
    foregroundColor: "white"


//    tileBackgroundColor:
//    tileOverlayColor: "#DDE8B4"
    tileOverlayIconColor: foregroundColor

    accentColor: consolinnoMedium
    iconColor: consolinnoLight

    blue: "#009EE2"
    red: "#E20613"
    yellow: "#FFEC00"
}
