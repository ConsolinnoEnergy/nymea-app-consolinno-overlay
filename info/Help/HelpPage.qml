import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQml
import Nymea 1.0
import QtQuick.Layouts

import "../../components"
import "../../delegates"


Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Help")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin + root.navigationFooterHeight

        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout{
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: app.margins

            RowLayout{
                VerticalDivider
                {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }
            }


            RowLayout{
                ConsolinnoItemDelegate{
                    id: manual
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Manual")
                    Layout.fillWidth: true
                    onClicked:{

                        pageStack.push("ManualPage.qml")


                    }
                }
            }

            RowLayout{
                VerticalDivider
                {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }
            }

            RowLayout{
                ConsolinnoItemDelegate{
                    id: contact
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Installer contact")
                    Layout.fillWidth: true
                    onClicked:{

                        pageStack.push("ContactPage.qml")

                    }
                }
            }

            RowLayout{
                VerticalDivider
                {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }
            }

            RowLayout{
                ConsolinnoItemDelegate{
                    id: service
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.fillWidth: true
                    text: qsTr("%1 Service").arg(Configuration.appBranding)
                    onClicked:{

                        pageStack.push("ServicePage.qml")

                    }
                }

            }

            RowLayout{
                Label{
                    id: infoManual
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: 20
                    Layout.fillWidth: true
                    text: qsTr("Under 'Manual' you will find current instructions for the app.")
                    wrapMode: Text.WordWrap
                }

            }

            RowLayout{
                Label{
                    id: infoDevice
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("If you have any problems with your system, please contact the installer. Under 'Installation contact' the installer's details are stored (if he has entered them in the app).")

                }

            }

            RowLayout{
                Label{
                    id: infoLeaflet
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: 10
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("If there is a problem with the %1 itself, then contact %2 Service.").arg(Configuration.deviceName).arg(Configuration.appBranding)
                }

            }
        }
    }


}
