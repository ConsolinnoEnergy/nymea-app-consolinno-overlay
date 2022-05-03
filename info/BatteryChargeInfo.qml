import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
 import QtGraphicalEffects 1.15
import Nymea 1.0

import "../components"
import "../delegates"

Page {

    header: NymeaHeader {
        id: header
        text: qsTr(thing.name)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }
}
