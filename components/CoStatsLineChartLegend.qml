pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// CoStatsLineChartLegend
//
// Row of CoLegendPill controls, one per entry in "series" (the same array
// passed to CoStatsLineChart), letting the user toggle the visibility of
// each line. Tapping a pill emits "seriesVisibilityToggled(index, visible)" -
// the consumer (whoever owns the "series" array passed to both this legend
// and CoStatsLineChart) is expected to update that array's entry and
// re-assign it (with a new array reference) to both components in response,
// since "series" is a plain JS array, not a shared/bindable model.
Row {
    id: root

    required property var series

    signal seriesVisibilityToggled(int index, bool visible)

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

            onToggled: root.seriesVisibilityToggled(index, checked)
        }
    }
}
