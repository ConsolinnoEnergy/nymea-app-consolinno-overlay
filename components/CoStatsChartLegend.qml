pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// CoStatsChartLegend
//
// Wrapping row (Flow) of CoLegendPill controls, one per entry in "series"
// (the same array passed to CoStatsLineChart/CoStatsBarChart), letting the
// user toggle the visibility of each series. Uses Flow rather than Row so
// pills that don't fit on one line wrap onto the next instead of being
// pushed outside the card and becoming unreachable. Tapping a pill emits
// "seriesVisibilityToggled(index, visible)" - the consumer (whoever owns the
// "series" array passed to both this legend and the chart) is expected to
// update that array's entry and re-assign it (with a new array reference) to
// both components in response, since "series" is a plain JS array, not a
// shared/bindable model.
Flow {
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
