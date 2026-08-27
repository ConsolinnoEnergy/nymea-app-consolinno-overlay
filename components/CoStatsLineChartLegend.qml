pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// CoStatsLineChartLegend
//
// Row of CoLegendPill controls, one per entry in "series" (the same array
// passed to CoStatsLineChart), letting the user toggle the visibility of
// each line. Tapping a pill toggles that series' "visible" flag and
// re-assigns "series" with a new array reference so property bindings on
// CoStatsLineChart pick up the change.
Row {
    id: root

    required property var series

    spacing: 8

    Repeater {
        model: root.series

        delegate: CoLegendPill {
            required property var modelData
            required property int index

            text: modelData.name
            pillColor: modelData.color
            pillAccentColor: modelData.color
            checked: modelData.visible !== false

            onToggled: {
                var updated = root.series.slice()
                updated[index] = Object.assign({}, updated[index], { visible: checked })
                root.series = updated
            }
        }
    }
}
