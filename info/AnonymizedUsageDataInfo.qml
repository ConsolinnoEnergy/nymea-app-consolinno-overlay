import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2

import "../components"
import "../delegates"

ColumnLayout {
    id: root

    signal closeRequested()

    spacing: 0

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("What are anonymized usage data?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        wrapMode: Text.WordWrap
        text: qsTr("With this release, fully anonymized usage data is transmitted to Consolinno. This data does not contain any personal information and does not allow any conclusions to be drawn about individual persons or locations. All identifying characteristics are irrevocably removed before transmission.")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 16
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("What is this data used for?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        wrapMode: Text.WordWrap
        text: qsTr("The anonymized data is used exclusively for research purposes as well as for the improvement of products and services. They help to further develop optimization algorithms, improve system stability and design new functions to meet demand. Your data thus makes a valuable contribution to the further development of the energy transition.")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 16
        wrapMode: Text.WordWrap
        font.bold: true
        font.pixelSize: 16
        text: qsTr("Will my data be shared with third parties?")
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 8
        wrapMode: Text.WordWrap
        text: qsTr("No. The anonymized usage data is not sold to third parties or used for advertising purposes. You can revoke this release at any time. For more information, please visit www.consolinno.de/hems-datenschutz.")
    }
}
