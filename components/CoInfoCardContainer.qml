import QtQuick
import QtQuick.Layouts
import Nymea

GridLayout {
    anchors.leftMargin: Style.margins
    anchors.rightMargin: Style.margins
    columnSpacing: Style.margins
    rowSpacing: Style.margins
    columns: Window.width > 600 ? 2 : 1
    uniformCellHeights: columns > 1
    uniformCellWidths: columns > 1
}
