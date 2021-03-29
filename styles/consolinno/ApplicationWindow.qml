import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

ApplicationWindow {
    // Identifier used for branding (e.g. to register for push notifications)
    property string branding: "consolinno"

    // Branding names visible to the user
    property string appBranding: "Consolinno Energy"
    property string coreBranding: "Leaflet"

    // Additional MainViews
    property var additionalMainViews: ListModel {
        ListElement { name: "acme"; source: "consolinno/EnergyView"; displayName: qsTr("Energy"); icon: "consolinno/leaf" }
    }

    // Main views filter: Only those main views are enabled
    property var mainViewsFilter: ["acme", "things"]
}
