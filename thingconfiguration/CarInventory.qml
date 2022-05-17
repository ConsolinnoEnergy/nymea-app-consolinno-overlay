import QtQuick 2.0
import QtQuick.Controls 2.15
import Nymea 1.0

Page{
    header: NymeaHeader {
        id: header
        text: qsTr("Car inventory")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Label{
        text: "new page new me"
    }
}
