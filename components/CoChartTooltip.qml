import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

// CoChartTooltip
//
// Non-modal popup showing the exact values behind a selected point/category
// of a statistics chart (CoStatsLineChart/CoStatsBarChart): a title (e.g. the
// selected day) plus one row per data series (color swatch, name, formatted
// value). Content-agnostic - the caller (CoStatsView.qml) builds "entries"
// from whatever series/values are relevant to the current chart and period,
// re-using the same {name, color, borderColor} shape already used for
// CoStatsChartLegend, only extended with a pre-formatted "valueText" (e.g.
// "9,45 kWh") - formatting/rounding/unit selection stays the caller's
// responsibility, same as everywhere else in the statistics page.
//
// Positioning is driven by two rects in window/overlay coordinates (both
// callers are expected to compute e.g. via mapToItem(Overlay.overlay, ...)):
//   - anchorRect: bounding box of the selected chart position (e.g. the
//     tapped category's bar stacks, or a thin rect around the selected
//     timestamp on the line chart). The tooltip is placed horizontally
//     beside this rect (preferring the right side).
//   - chartRect: bounding box of the chart's plot area. The tooltip is
//     centered vertically on this rect.
// Call "showAt(anchorRect, chartRect, title, entries)" to position, fill in
// content and open in one step.
Popup {
    id: root

    // ── Content ──────────────────────────────────────────────────────────
    property string title: ""
    // [{ name: string, color: color, borderColor: color, valueText: string }]
    property var entries: []

    // Horizontal gap between "anchorRect" and the tooltip.
    readonly property int anchorGap: Style.smallMargins

    signal dismissRequested()

    // anchorRect/chartRect: rect, both in the same coordinate space as this
    // Popup's parent (typically Overlay.overlay - see file doc comment).
    function showAt(anchorRect, chartRect, tooltipTitle, tooltipEntries) {
        title = tooltipTitle
        entries = tooltipEntries
        // Positioning (x/y bindings below) reads anchorRect/chartRect, so
        // they must be assigned before open() for the initial position to
        // be correct (there's no other event to re-trigger the bindings
        // between now and the popup becoming visible).
        d.anchorRect = anchorRect
        d.chartRect = chartRect
        open()
    }

    // ── Private state & positioning ──────────────────────────────────────
    QtObject {
        id: d
        property rect anchorRect: Qt.rect(0, 0, 0, 0)
        property rect chartRect: Qt.rect(0, 0, 0, 0)
    }

    modal: false
    focus: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

    onClosed: root.dismissRequested()

    // Horizontal: prefer beside anchorRect on the right; flip to the left
    // if there isn't enough room; clamp to the window as a last resort (in
    // case neither side fully fits, e.g. a very narrow window).
    //
    // Guarded against "Overlay.overlay" being null: it only becomes valid
    // once this Popup is actually part of a window (i.e. after open() has
    // run at least once) - reading ".width" on it unconditionally would
    // throw on this binding's very first evaluation (which happens right
    // away, at component creation, long before any tap ever calls
    // showAt()/open()). Since that first evaluation throws *before* QML
    // gets to register a dependency on ".width", the binding would then
    // permanently stop re-evaluating, even once "Overlay.overlay" becomes
    // valid afterwards - leaving the popup stuck with a bogus/invisible
    // position forever. Checking "Overlay.overlay" itself first (instead of
    // "Overlay.overlay.width" directly) keeps the dependency on the
    // attached property alone until it's actually safe to dereference.
    x: {
        if (!Overlay.overlay)
            return 0
        var rightX = d.anchorRect.x + d.anchorRect.width + anchorGap
        var leftX = d.anchorRect.x - anchorGap - width
        var x
        if (rightX + width <= Overlay.overlay.width) {
            x = rightX
        } else if (leftX >= 0) {
            x = leftX
        } else {
            x = rightX
        }
        return Math.max(0, Math.min(x, Overlay.overlay.width - width))
    }

    // Vertical: centered on chartRect, may extend beyond it, but clamped to
    // stay fully within the window. See the "x" binding above for why
    // "Overlay.overlay" is null-checked before being dereferenced.
    y: {
        if (!Overlay.overlay)
            return 0
        var y = d.chartRect.y + (d.chartRect.height - height) / 2
        return Math.max(0, Math.min(y, Overlay.overlay.height - height))
    }

    padding: Style.smallMargins

    background: Rectangle {
        color: Style.colors.components_Statistics_Tooltip_background
        radius: Style.cornerRadius
    }

    contentItem: ColumnLayout {
        spacing: Style.margins

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.smallMargins

            Text {
                text: root.title
                font: Style.newSmallFont
                color: Style.colors.typography_Basic_Default
            }

            Item { Layout.fillWidth: true }

            ColorIcon {
                name: Qt.resolvedUrl("qrc:/icons/close.svg")
                color: Style.colors.typography_Basic_Default
                size: 16

                TapHandler {
                    onTapped: root.close()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.extraSmallMargins

            Repeater {
                model: root.entries

                delegate: RowLayout {
                    id: entryDelegate
                    required property var modelData

                    Layout.fillWidth: true
                    spacing: Style.smallMargins

                    Rectangle {
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        radius: width / 2
                        color: entryDelegate.modelData.color
                        border.color: entryDelegate.modelData.borderColor
                        border.width: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: entryDelegate.modelData.name
                        font: Style.newExtraSmallFont
                        color: Style.colors.typography_Basic_Default
                        elide: Text.ElideRight
                    }

                    Text {
                        text: entryDelegate.modelData.valueText
                        font: Style.newExtraSmallFont
                        color: Style.colors.typography_Basic_Default
                    }
                }
            }
        }
    }
}
