import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
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

    // Caps the popup's width so it can never grow wide enough to cover its
    // own "anchorRect" (e.g. the line chart's selected-timestamp highlight
    // line - see CoStatsLineChart.qml) - without this, a long series/device
    // name (Repeater entry below) would let the popup's natural
    // (implicit) width grow arbitrarily, which the "x" positioning below
    // can't compensate for. Series names are elided (see the Text's
    // "elide: Text.ElideRight" below) to fit within this width instead.
    //
    // Half the window width (minus the anchor gap) is the worst case that
    // still guarantees "anchorRect" stays uncovered: if it sits exactly in
    // the middle of the window, only half the window is available on
    // whichever side the tooltip ends up on. Guarded against
    // "Overlay.overlay" being null the same way "x"/"y" below are (see
    // their doc comment).
    readonly property real maxContentWidth: Overlay.overlay ? (Overlay.overlay.width / 2 - anchorGap) : 0

    // Item to sample for the blurred background (see "background" below) -
    // typically the caller's own root Item, i.e. whatever page content this
    // tooltip is shown over. Must NOT be an ancestor of Overlay.overlay
    // itself (e.g. Overlay.overlay), or the blur would try to capture this
    // very popup, which is a child of Overlay.overlay.
    property Item blurSourceItem: null

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

    // Cap the popup's actual width at "maxContentWidth" (see its doc
    // comment above) - "implicitWidth" still reflects the *unconstrained*
    // natural size (driven by contentItem's ColumnLayout), so this only
    // ever shrinks the popup, never grows it beyond what its content
    // actually needs.
    width: Math.min(implicitWidth, maxContentWidth)

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

    // Frosted-glass background: the popup can appear anywhere over the
    // chart/page, so - like CoHeader.qml elsewhere in this app - a live
    // snapshot of whatever is currently behind it (taken from
    // "blurSourceItem", the caller's own page content - see its doc comment
    // above) is blurred and covered with the semi-transparent tooltip
    // background color/token (already given some alpha in Style.qml) for
    // tinting. The whole thing is masked to rounded corners as one unit via
    // "layer"/OpacityMask, since neither the blur nor a plain "radius" on
    // the tint alone would otherwise clip the (rectangular) blurred image
    // to match the tint's rounded shape.
    background: Item {
        id: bg

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: bg.width
                height: bg.height
                radius: Style.cornerRadius
            }
        }

        // Swallow every press within the popup's bounds: Popup's own
        // background/contentItem are plain Rectangle/Layout items with no
        // input handling of their own, so without this, a press here
        // Swallow every press within the popup's bounds: Popup's own
        // background/contentItem are plain Rectangle/Layout items with no
        // input handling of their own, so without this, a press here
        // (anywhere not already covered by e.g. the close icon's
        // TapHandler below) would otherwise fall straight through to
        // whatever chart is behind this (non-modal) popup - letting a
        // click-and-drag on the tooltip itself pan/select on that chart
        // underneath while the tooltip stays open and visually "stuck".
        // "preventStealing" is required here: without it, MouseArea
        // willingly cedes its grab to e.g. the chart's own pan DragHandler
        // once the drag exceeds its threshold (the same mechanism that
        // normally lets a Flickable pan through a plain MouseArea overlay)
        // - which is exactly the unwanted passthrough this MouseArea exists
        // to prevent.
        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onPressed: {}
        }

        ShaderEffectSource {
            id: blurSource
            anchors.fill: parent
            sourceItem: root.blurSourceItem
            // Map this Item's own bounds (local 0,0 - width,height) into
            // "blurSourceItem"'s coordinate space, so the sampled area
            // always matches wherever the popup ends up being placed -
            // regardless of "blurSourceItem"'s own position/coordinate
            // system (unlike "x/y" above, this doesn't need to go via
            // Overlay.overlay/root.parent at all). Note: this must be done
            // via "bg" (a real Item), not "root" - "root" is the Popup
            // itself, which (unlike its background/contentItem) is a plain
            // QObject with no "mapToItem".
            sourceRect: root.blurSourceItem
                        ? bg.mapToItem(root.blurSourceItem, 0, 0, bg.width, bg.height)
                        : Qt.rect(0, 0, 0, 0)
            visible: false
            live: true
        }

        FastBlur {
            anchors.fill: parent
            source: blurSource
            radius: 32
        }

        Rectangle {
            anchors.fill: parent
            color: Style.colors.components_Statistics_Tooltip_background
        }
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
