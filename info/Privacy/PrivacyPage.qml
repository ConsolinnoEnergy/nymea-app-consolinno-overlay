import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

Page {

    header: NymeaHeader {
        text: qsTr("Privacy policy and license agreement")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }


    ColumnLayout {
                   anchors { top: parent.top; bottom: parent.bottom;  horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; bottomMargin: Style.bigMargins }
                   width: Math.min(parent.width, 450)


                   Flickable {
                       Layout.fillHeight: app.height/2
                       Layout.fillWidth: true
                       Layout.alignment: Qt.AlignHCenter
                       Layout.margins: Style.margins
                       contentHeight: textArea.height
                       clip: true

                       TextArea {
                           id: textArea
                           width: parent.width
                           font: Style.smallFont
                           wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                           textFormat: Text.RichText
                           readOnly: true
                           text: ""
                        }

                      Component.onCompleted: {
                        loadHtmlFile("./privacy_agreement_de_DE.html");
                      }

                      function loadHtmlFile(fileName) {
                        var fileUrl = Qt.resolvedUrl(fileName); // Resolve the file path
                        var file = Qt.createQmlObject('import QtQml 2.15; File {}', textArea, 'dynamicFile');
                        
                        file.open(fileUrl, File.ReadOnly);
                        var fileContent = file.readAll();
                        file.close();

                        textArea.text = fileContent;
                      }
               }


               RowLayout{
                   CheckBox{
                       id: accountCheckbox
                       Layout.alignment: Qt.AlignLeft

                   }

                   Label {
                       Layout.fillWidth: true
                       wrapMode: Text.WordWrap
                       horizontalAlignment: Text.AlignHCenter
                       text: qsTr("Yes I agree to open a Useraccount, according to part 6 ")
                   }
               }


               RowLayout{
                   CheckBox {
                       id: policyCheckbox
                       Layout.alignment: Qt.AlignLeft
                       Accessible.name: this.id
                       Accessible.checkable: true
                   }


                   Label {
                       Layout.fillWidth: true
                       wrapMode: Text.WordWrap
                       horizontalAlignment: Text.AlignHCenter
                       text: qsTr('I confirm that I have read the the agreement and am accepting it.')
                   }
               }

               }



}
