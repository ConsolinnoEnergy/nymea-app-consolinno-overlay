import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

// CoHeadlineTabBar
//
// Variant of CoTabBar for headline-style tab switchers (e.g. the
// "Energiebilanz"/"Verbrauch" chart tab switcher, using CoHeadlineTabButton
// children): fully transparent background (no pill), tab buttons packed to
// the left with a fixed spacing, plus a fixed pair of prev/next chevron
// buttons on the right (mirroring the Figma design's carousel navigation,
// which normally moves between more tabs than are currently implemented -
// see CoStatsView.qml for which tabs exist today).
//
// Copied and adapted from CoTabBar rather than making CoTabBar itself
// configurable, since CoTabBar is also used for the plain segmented-control
// style switcher (CoTabButton) and the two look/behave differently enough
// that sharing one component would need more conditional logic than it's
// worth.
Item {
    id: root

    default property alias content: tabButtonLayout.data

    // Enabled state of the two chevron buttons is fully controlled by the
    // consumer (e.g. bound to "can we move further in that direction"),
    // since this component has no notion of how many tabs exist beyond the
    // ones currently placed in it.
    property bool previousEnabled: true
    property bool nextEnabled: true

    signal previousClicked()
    signal nextClicked()

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: Style.margins

        RowLayout {
            id: tabButtonLayout
            Layout.fillWidth: true
            spacing: Style.margins
        }

        CoIconButton {
            width: 36
            height: 36
            enabled: root.previousEnabled
            icon: Qt.resolvedUrl("qrc:/icons/chevron_backward.svg")
            onClicked: root.previousClicked()
        }

        CoIconButton {
            width: 36
            height: 36
            enabled: root.nextEnabled
            icon: Qt.resolvedUrl("qrc:/icons/chevron_forward.svg")
            onClicked: root.nextClicked()
        }
    }
}
