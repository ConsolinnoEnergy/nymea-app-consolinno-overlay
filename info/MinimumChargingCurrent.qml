import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0

import "../components"
import "../delegates"

Page {

    header: NymeaHeader {
        id: header
        text: qsTr("Minimum Charging Current info")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    InfoTextInterface{
        infotext: qsTr("Bei einigen Fahrzeugen wird der Ladevorgang nach einer Pause bzw. Unterbrechung nicht wieder fortgesetzt. Das kann im Lademodus "kostenoptimiertes Laden" oder "nur Solarstrom" der Fall sein, wenn nicht ausreichend Solarstrom zur Verfügung steht. Die Einstellung eines Mindeststroms sorgt dafür, dass das Fahrzeug auch wenn kein Solarstrom zur Verfügung steht, mit dem Mindeststrom geladen wird, und es somit zu keiner Unterbrechung kommt. Der Mindestladestrom sollte möglichst gering gewählt werden.")
    }
}
