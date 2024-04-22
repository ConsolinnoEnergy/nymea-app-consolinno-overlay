import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2

import "../../components"
import "../../delegates"


Page {

    header: ConsolinnoHeader {
        text: qsTr("IT Security")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: false
    }

    ColumnLayout{
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: app.margins
            leftMargin: app.margins
            rightMargin: app.margins
        }

        spacing: Style.bigMargins

        Column {
            Layout.fillWidth: true

            Label {
                text: qsTr("IT security tips")
                font.bold: true
            }

            Label {
                text: qsTr('<html><style type="text/css"></style><p>We recommend the <a href="https://www.bsi.bund.de/DE/Themen/Verbraucherinnen-und-Verbraucher/Informationen-und-Empfehlungen/Cyber-Sicherheitsempfehlungen/cyber-sicherheitsempfehlungen_node.html"> basis tips</a> from the BSI. </p></html>')

                onLinkActivated:{
                    Qt.openUrlExternally(link)
                }
            }
        }



        Column {
            Layout.fillWidth: true

            Label {
                text: qsTr("Security incidents")
                font.bold: true
            }

            Label {
                width: parent.width
                text: qsTr('<html><style type="text/css"></style><p>You can report incidents via E-Mail: <br> <a href="itsecurity@consolinno.de">itsecurity@consolinno.de</a> </p></html>')

                onLinkActivated:{
                    Qt.openUrlExternally(link)
                }
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr('<html><style type="text/css"></style><p>For security experts, please see <a href="https://consolinno.de/.well-known/security.txt">https://consolinno.de/.well-known/security.txt</a> </p></html>')

            onLinkActivated:{
                Qt.openUrlExternally(link)
            }
        }
    }
}
