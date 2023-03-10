import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import 'qrc:/ui/components'
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root


    showBackButton: false
    showNextButton: false
    background: Item{}
    // change this to privacyPolicyComponent when the Policy is there
    onNext: pageStack.push(privacyPolicyComponent)

    function exitWizard() {
        pageStack.pop(root, StackView.Immediate)
        pageStack.pop()
    }

    content: ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; right: parent.right; left: parent.left }
        //width: Math.min(parent.width, 450)

        Label {
            Layout.fillWidth: true
            text: qsTr('Terms of Use')
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font: Style.bigFont
        }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.margins
            contentHeight: layoutID.height
            clip: true


            ColumnLayout{
                id: layoutID
                Layout.fillWidth: true

                Label {
                    id: allgemein
                    width: app.width
                    font.bold: true
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    text: qsTr("1. Allgemeines")

                }


                Text{
                    id: allgemeinText
                    //Layout.fillWidth: true
                    Layout.preferredWidth: app.width - app.margins*2
                    color: Material.foreground
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    //readOnly: true
                    text: qsTr("(1) Consolinno Energy GmbH hat eine Software entwickelt, welche als Applikation auf Android und IOS-Systemen benutzt werden kann. Die Software verbindet sich mit einem Energy Management Systems genannt Leaflet HEMS. Das hat dann die Aufgabe in Verbindung mit einer Photovoltaikanlage den Eigenverbrauch der PV-Energie zu maximieren. Parallel ist die Funktion Black-out Schutz integriert. Damit wird der Ladestrom einer Ladeeinrichtung dynamisch begrenzt. Es kommt nicht zum Ausl??sen der Sicherung.")

                }






                Text{
                    id: allgemeinText2
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Die Software erm??glicht es, durch die Steuerung einer E-Ladeeinrichtung, einer W??rmepumpe, Hausger??te (Waschmaschine, Trockner, Sp??lmaschine) und dem Einbinden einer Batterie den Eigenbedarf der erzeugten PV-Energie signifikant zu steigern.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Dadurch wird CO2 und Kosten eingespart.")

                }

                Text{
                    id: allgemeinText4
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Diese allgemeinen Lizenzbestimmungen gelten f??r s??mtliche Lizenzvertr??ge mit dem Kunden ??ber die Module der Software und dem HEMS Produkt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Die Software wird von der Consolinno Energy GmbH kostenfrei Kunden vom HEMS ??ber Appstores angeboten.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die Kunden sind f??r das ordnungsgem????e Installieren der Hard- und Software verantwortlich.")

                }


                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("2.Lizenzgegenstand")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Consolinno Energy GmbH gew??hrt dem Kunden das ausschlie??liche Recht die in der Vereinbarung n??her beschriebene Software innerhalb Deutschlands zu nutzen. Es wird ein nicht-ausschlie??liches und nicht-??bertragbares Nutzungsrecht an der Software einger??umt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Soweit dies f??r die vertragsgem????e Nutzung erforderlich ist, darf die Software vervielf??ltigt werden.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("??ber die Appstores kann der Kunde mit dem jeweiligen Betriebssystem das Programm laden und installieren")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Im ??brigen ist der Kunde zu einer Vervielf??ltigung oder ??berlassung an Dritte nicht berechtigt, soweit gesetzlich nicht anderes bestimmt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Der Kunde ist nicht berechtigt, die Software zu ver??ndern und zu bearbeiten, es sei denn, es handelt sich bei der ??nderung bzw. Bearbeitung um eine f??r die vertragsgem????e Nutzung der Software erforderliche Beseitigung eines Mangels, mit welcher sich die Consolinno Energy GmbH in Verzug befindet.")

                }


                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("3.Lizenzgeb??hr")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Der Kunde hat mit dem Erwerb des HEMS-Ger??tes die Software kostenfrei von den APP Stores geladen und kann diese benutzen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Im Rahmen der Weiterentwicklung k??nnen Softwaremodule auch f??r eine unbefristete Nutzungsdauer k??uflich erworben werden.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.bold: true
                    font.pixelSize: 15
                    text: qsTr("4.Softwareauslieferung und Installation")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Consolinno Energy GmbH liefert die Software an den Kunden ??ber den Appstore von Apple oder Google aus.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Neben der Software wird Consolinno Energy GmbH dem Kunden eine Installationsanleitung des Ger??tes HEMS sowie eine Dokumentation zum Download anbieten.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("3) Consolinno Energy GmbH schuldet keine Installation der Software auf den Systemen des Kunden; f??r diese ist der Kunde allein ver-antwortlich.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("5.Instandhaltung")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Consolinno Energy GmbH ist zur Aufrechterhaltung der vertraglich vereinbarten Beschaffenheit der Software w??hrend der Vertragslaufzeit ('Instandhaltung') verpflichtet. Die vertraglich geschuldete Beschaffenheit der Software bestimmt sich nach der zugesagten Funktion des HEMS Produktes. Up Dates erfolgen ??ber eine Internetverbindung.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Consolinno Energy GmbH ist zu einer ??nderung, Anpassung und Weiterentwicklung der Software nur dann verpflichtet, wenn das mit dem Kunden gesondert vereinbart ist. Ohne eine solche gesonderte Vereinbarung ist die Consolinno Energy GmbH nicht zu einer Weiterentwicklung der Software verpflichtet.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("6.Gew??hrleistung")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Sollte dem Kunden M??ngel an der Software, am Ger??t oder an der Dokumentation feststellen, so hat der Kunde das der Consolinno Energy GmbH mitzuteilen. Das kann zum Beispiel per Mail erfolgen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Ein Mangel liegt nicht vor, wenn die vom Kunden verwendete Hardware und /oder Software nicht den spezifizierten Anforderungen entspricht.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Consolinno Energy GmbH wird die angezeigten M??ngel an der Software und an der Dokumentation innerhalb einer angemessenen Frist zu beheben. Im Rahmen der M??ngelbeseitigung hat Consolinno Energy GmbH ein Wahlrecht zwischen Nachbesserung und Ersatzlieferung. Die Kosten der M??ngelbeseitigung tr??gt Consolinno Energy GmbH. Kosten f??r Ausfall, entgangener Gewinn, Ein- und Ausbaukosten oder ??hnliches werden nicht erstattet.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Schl??gt die hierin geschuldete M??ngelbeseitigung fehl, ist die Kunde zur au??erordentlichen K??ndigung des betreffenden Vertrages gem???? ?? 543 Abs. 2 S. 1 Nr. 1 BGB berechtigt.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("8.Haftung")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Der Lizenzgeber haftet unbeschr??nkt:

?? bei Arglist, Vorsatz oder grober Fahrl??ssigkeit;

?? im Rahmen einer von ihm ausdr??cklich ??bernommenen Garantie;

?? f??r Sch??den aus der Verletzung des Lebens, des K??rpers oder der Gesundheit;

?? nach den Vorschriften des Produkthaftungsgesetzes")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Im ??brigen ist eine Haftung der Consolinno Energy GmbH f??r direkte und indirekte Sch??den ausgeschlossen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Open Source

Open Source Module sind in der APP und in der Ger??tesoftware enthalten. Es gelten f??r diese Module die entsprechende Garantie und Haftungsbedingungen. Sollte das nicht m??glich sein, dann gilt die Regelung im jeweiligen Anwenderland.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("9.Vertragsdauer und Vertragsbeendigung")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Der Lizenzvertrag tritt mit der Akzeptanz der Lizenzbestimmungen vor der Installation in Kraft in gilt auf unbestimmte Dauer.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Das Recht beider Parteien zur jederzeitigen au??erordentlichen und fristlosen K??ndigung aus wichtigem Grund bleibt unber??hrt. Ein wichtiger Grund liegt insbesondere vor, wenn der Lizenzgeber oder die Lizenznehmerin vors??tzlich oder fahrl??ssig gegen eine wesentliche Pflicht aus diesen Lizenzbestimmungen verst????t und deswegen der k??ndigenden Partei das Festhalten am Lizenzvertrag nicht mehr zumutbar ist. Der Lizenzgeber ist hiernach insbesondere zur au??erordentlichen und fristlosen K??ndigung des Lizenzvertrages berechtigt, wenn die Lizenznehmerin die ihr einger??umten Nutzungsbefugnisse ??berschreitet und ihre Verletzungshandlungen nicht innerhalb einer angemessenen Frist abstellt, wenn der Lizenzgeber diese zuvor zur Unterlassung dieser Verletzungshandlungen abgemahnt hat.")

                }


                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die K??ndigung des Lizenzvertrages bedarf der Schriftform.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Consolinno Energy GmbH kann die Pflege des Programmes ohne nennen von Gr??nden einstellen")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("11.Schlussbestimmungen")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Sollte eine dieser Lizenzbestimmungen oder eine sp??ter in diesen Lizenzvertrag aufgenommene Bestimmung ganz oder teilweise nichtig oder undurchf??hrbar sein oder werden oder sollte sich eine L??cke in diesen Lizenzbestimmungen herausstellen, wird dadurch die Wirksamkeit der ??brigen Bestimmungen nicht ber??hrt (Erhaltung). Es ist der ausdr??ckliche Wille der Parteien, hierdurch die Wirksamkeit der ??brigen Bestimmungen unter allen Umst??nden aufrechtzuerhalten und damit ?? 139 BGB insgesamt abzubedingen. Anstelle der nichtigen oder undurchf??hrbaren Bestimmung oder zur Ausf??llung der L??cke gilt mit R??ckwirkung diejenige wirksame und durchf??hrbare Regelung als bestimmt, die rechtlich und wirtschaftlich dem am n??chsten kommt, was die Parteien gewollt haben oder nach dem Sinn und Zweck des Lizenzvertrages gewollt h??tten, wenn sie diesen Punkt bei Abschluss dieser Vereinbarung bzw. bei Aufnahme der Bestimmung bedacht h??tten; beruht die Nichtigkeit einer Bestimmung auf einem darin festgelegten Ma?? der Leistung oder der Zeit (Frist oder Termin), so gilt die Bestimmung mit einem dem urspr??nglichen Ma?? am n??chsten kommenden rechtlich zul??ssigen Ma?? als vereinbart (Ersetzungsfiktion). Ist die Ersetzungsfiktion nicht m??glich, ist anstelle der nichtigen oder undurchf??hrbaren Bestimmung oder zur Schlie??ung der L??cke eine Bestimmung bzw. Regelung nach inhaltlicher Ma??gabe des vorstehenden Satzes zu treffen (Ersetzungsverpflichtung). Betrifft die Nichtigkeit oder L??cke eine beurkundungspflichtige Bestimmung, so ist die Regelung bzw. die Bestimmung in notariell beurkundeter Form zu vereinbaren.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) ??nderungen und Erg??nzungen des betreffenden Lizenzvertrages einschlie??lich dieser Klausel bed??rfen der Schriftform, soweit nicht etwas anderes bestimmt ist")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die Parteien d??rfen den Lizenzvertrag sowie Rechte und Pflichten aus dem Lizenzvertrag nur mit vorheriger schriftlicher Zustimmung der jeweils anderen Partei auf einen Dritten ??bertragen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Die Geltung der Allgemeinen Gesch??ftsbedingungen der Lizenznehmerin werden ausdr??cklich ausgeschlossen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(5) Ausschlie??licher Gerichtsstand f??r alle Streitigkeiten aus oder im Zusammenhang mit dem Lizenzvertrag ist der Sitz des Lizenzgebers, Regensburg. Der Lizenzgeber bleibt berechtigt, am allgemeinen Gerichtsstand der Lizenznehmerin zu klagen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Anschrift des Lizenzgebers
Consolinno Energy GmbH, Franz-Mayer-Stra??e 1, 93053 Regensburg")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Tel 0941 20300 333
Mail service@consolinno.de")

                }







            }





        }


        RowLayout{
            CheckBox{
                id: readCheckbox
                Layout.alignment: Qt.AlignHCenter

            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Yes I read the Term of Use and agree")
            }
        }


        Button {
            Layout.alignment: Qt.AlignHCenter
            text: readCheckbox.checked ? qsTr('next') : qsTr('cancel')
            Layout.preferredWidth: 200
            background: Rectangle{
                color: readCheckbox.checked  ? '#87BD26' : 'grey'
                radius: 4
            }


            onClicked: {
                if (readCheckbox.checked) {
                    root.next()
                } else {
                    Qt.quit()
                }
            }
        }
    }




    Component{
        id: demoModeComponent
        ConsolinnoWizardPageBase {
            id: demoModePage

            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(connectionInfo)
            onBack: pageStack.pop()

            background: Item {}
            content: ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.topMargin: Style.margins
                spacing: Style.hugeMargins
                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height / 4
                    source: '/ui/images/intro-bg-graphic.svg'
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(parent.width, 300)

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font: Style.bigFont
                        text: qsTr('HEMS')
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: qsTr('Make sure that the Leaflet is operational and connected to the network.')
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr('Start setup')
                        Layout.preferredWidth: 200
                        onClicked: demoModePage.next()
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr('Demo mode')
                        Layout.preferredWidth: 200
                        onClicked:
                        {
                            var host = nymeaDiscovery.nymeaHosts.createWanHost('Demo server', 'nymeas://hems-demo.consolinno-it.de:31222')
                            engine.jsonRpcClient.connectToHost(host)
                        }
                    }
                }
            }


        }


    }






    Component {
        id: privacyPolicyComponent
        ConsolinnoWizardPageBase {
            id: privacyPolicyPage

            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(demoModeComponent)
            onBack: pageStack.pop()

            background: Item {}
            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; right: parent.right; left: parent.left }
                width: Math.min(parent.width, 450)

                Label {
                    Layout.fillWidth: true
                    text: qsTr('Privacy policy and license agreement HEMS (09/2022)')
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font: Style.bigFont
                }

                Flickable {
                    Layout.fillHeight: true
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
                            text:
"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0 Transitional//EN'>" +
"<html>"+
" <head>"+
" <meta http-equiv='content-type' content='text/html; charset=utf-8'/>"+
" <title></title>"+
" <meta name='generator' content='LibreOffice 6.4.7.2 (Linux)'/>"+
" <meta name='author' content='Ghost'/>"+
" <meta name='created' content='2022-09-15T13:42:00'/>"+
" <meta name='changedby' content='B??hm, Patricia'/>"+
" <meta name='changed' content='2022-09-15T13:56:00'/>"+
" <meta name='AppVersion' content='16.0000'/>"+
" <meta name='DocSecurity' content='0'/>"+
" <meta name='HyperlinksChanged' content='false'/>"+
" <meta name='LinksUpToDate' content='false'/>"+
" <meta name='ScaleCrop' content='false'/>"+
" <meta name='ShareDoc' content='false'/>"+
" <style type='text/css'>"+
" @page { size:" + app.width + " " + app.height + "; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 2.5cm; margin-bottom: 1.25cm }"+
" p { margin-bottom: 0.25cm; direction: ltr; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" p.western { font-size: 8pt }"+
" p.cjk { font-size: 8pt; so-language: en-US }"+
" p.ctl { font-size: 8pt }"+
" h3 { margin-left: 1.27cm; margin-top: 0cm; margin-bottom: 0cm; direction: ltr; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" h3.western { font-size: 8pt; font-weight: bold }"+
" h3.cjk { font-size: 8pt; so-language: en-US; font-weight: bold }"+
" h3.ctl { font-size: 8pt }"+
" h3 { margin-left: 1.33cm; margin-top: 0cm; margin-bottom: 0cm; direction: ltr; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" h3.western { font-size: 8pt }"+
" h3.cjk { font-size: 8pt; so-language: en-US }"+
" h3.ctl { font-size: 8pt }"+
" p.sdfootnote-western { margin-bottom: 0cm; direction: ltr; font-size: 7pt; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" p.sdfootnote-cjk { margin-bottom: 0cm; direction: ltr; font-size: 7pt; so-language: en-US; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" p.sdfootnote-ctl { margin-bottom: 0cm; direction: ltr; font-family: 'Times New Roman'; font-size: 7pt; line-height: 115%; text-align: justify; orphans: 2; widows: 2; background: transparent }"+
" a:link { color: #0000ff; text-decoration: underline }"+
" a:visited { color: #800080; text-decoration: underline }"+
" a.sdfootnoteanc { font-size: 57% }"+
" </style>"+
" </head>"+
" <body lang='de-DE' link='#0000ff' vlink='#800080' dir='ltr'><p class='western' align='center' style='margin-left: 0.64cm; margin-bottom: 0cm'>"+
" </p>"+
" <p class='western' style='margin-bottom: 0cm'>Wir verarbeiten Ihre "+
" personenbezogenen Daten nach den aktuellen Regelungen der "+
" Bundesrepublik Deutschland und der Europ??ischen Union (EU). Dabei "+
" hat der Schutz Ihrer pers??nlichen Informationen h??chste Priorit??t. "+
" Im Folgenden erfahren Sie, welche Daten wir in welcher Form aufgrund "+
" welcher Rechtsgrundlage zu welchem Zweck wie lange verarbeiten, "+
" inwieweit Ihnen ein Widerspruchsrecht zusteht und wie sie dieses "+
" aus??ben k??nnen. Sollte Ihre Einwilligung notwendig sein, so wird "+
" Ihnen dies an entsprechender Stelle angezeigt und Sie haben die "+
" M??glichkeit, diese zu erteilen oder von einer Erteilung abzusehen. "+
" Selbstverst??ndlich haben Sie auch nach Erteilung Ihrer Einwilligung "+
" jederzeit das Recht, diese zu widerrufen.<font color='#333333'>&nbsp;</font></p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
"  "+
" </p>"+
" <ol>"+
" <h3 class='western'> 1. Verantwortlicher<span style='font-weight: normal'><a class='sdfootnoteanc' name='sdfootnote1anc' href='#sdfootnote1sym'><sup>1</sup></a></span><br/>"+
" Verantwortlich "+
" im Sinne der datenschutzrechtlichen Bestimmungen ist:</h3>"+
" </ol>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><b>Consolinno"+
" Energy GmbH</b></p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>vertreten"+
" durch den Gesch??ftsf??hrer</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Franz-Mayer-Stra??e"+
" 1</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>93053"+
" Regensburg</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Der "+
" zust??ndige betriebliche Datenschutzbeauftragte (bDSB) ist:</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Niklas "+
" Hanitsch</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Datenschutz "+
" hoch 4 GmbH</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Franz-Mayer-Str."+
" 1</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>93053"+
" Regensburg</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><a name='_Hlk514794356'></a>"+
" Wir m??chten Sie an dieser Stelle auf das <u>Recht zur Beschwerde bei"+
" der Aufsichtsbeh??rde</u> gem???? Art. 77 DSGVO hinweisen. Demnach"+
" hat jede betroffene Person unbeschadet eines anderweitigen"+
" Rechtsbehelfs das Recht auf Beschwerde bei der Aufsichtsbeh??rde,"+
" wenn sie der Ansicht ist, dass die Verarbeitung der sie betreffenden"+
" personenbezogenen Daten gegen die Datenschutz-Grundverordnung"+
" verst????t.</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Die "+
" Kontaktdaten der f??r den Verantwortlichen zust??ndigen"+
" Aufsichtsbeh??rde lauten:</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><font color='#000000'><span style='background: #ffffff'>Bayerisches"+
" Landesamt f??r Datenschutzaufsicht</span></font></p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Promenade"+
" 18</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>91522"+
" Ansbach</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol start='2'>"+
" <h3 class='western'> 2. Information ??ber Ihre Rechte als betroffene"+
" Person</h3>"+
" <ol>"+
" <h3 class='western'><a name='_Ref513466093'></a> 2.1 </h3> Bei <u>Vorliegen"+
" der gesetzlichen Voraussetzungen</u> haben Sie - sofern nicht ein"+
" gesetzlicher Ausnahmefall gegeben ist - <font color='#141414'>folgende"+
" Rechte hinsichtlich der Sie betreffenden personenbezogenen Daten:</font>"+
" </ol>"+
" </ol>"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ul>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Auskunft</b></u>"+
" (Art. 15 DSGVO): Sie haben das Recht, von dem Verantwortlichen eine"+
" Auskunft dar??ber zu verlangen, ob Sie betreffende personenbezogene"+
" Daten verarbeitet werden. Ist dies der Fall, so haben Sie das Recht"+
" auf Auskunft ??ber diese personenbezogenen Daten und damit im"+
" Zusammenhang stehende weitergehende Informationen.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Berichtigung</b></u>"+
" (Art. 16 DSGVO): Sie haben das Recht, von dem Verantwortlichen"+
" unverz??glich die Berichtigung Sie betreffender unrichtiger"+
" personenbezogener Daten zu verlangen. Unter Ber??cksichtigung der"+
" Zwecke der Verarbeitung haben Sie das Recht, die Vervollst??ndigung"+
" unvollst??ndiger personenbezogener Daten ??? auch mittels einer"+
" erg??nzenden Erkl??rung ??? zu verlangen.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>L??schung</b></u>"+
" (Art. 17 DSGVO): Sie haben das Recht, von dem Verantwortlichen zu"+
" verlangen, dass Sie betreffende personenbezogene Daten unverz??glich"+
" gel??scht werden, und der Verantwortliche ist verp???ichtet,"+
" personenbezogene Daten unverz??glich zu l??schen, sofern einer der"+
" Gr??nde des Art. 17 Abs. 1 DSGVO zutrifft und kein"+
" Ausnahmetatbestand eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Einschr??nkung der"+
" Verarbeitung</b></u> (Art. 18 DSGVO): Sie haben das Recht, von dem"+
" Verantwortlichen die Einschr??nkung der Verarbeitung (ehemals:"+
" Sperre) Ihrer personenbezogenen Daten zu verlangen, wenn eine der"+
" Voraussetzungen des Art. 18 Abs. 1 DSGVO gegeben ist und kein"+
" Ausnahmetatbestand eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Daten??bertragbarkeit</b></u>"+
" (Art. 20 DSGVO): Sie haben das Recht, die Sie betreffenden"+
" personenbezogenen Daten, die sie einem Verantwortlichen"+
" bereitgestellt haben, in einem strukturierten, g??ngigen und"+
" maschinenlesbaren Format zu erhalten, und sie haben das Recht, diese"+
" Daten einem anderen Verantwortlichen ohne Behinderung durch den"+
" Verantwortlichen, dem die personenbezogenen Daten bereitgestellt"+
" wurden, zu ??bermitteln, sofern die weiteren Voraussetzungen des"+
" Art. 20 Abs. 1 DSGVO gegeben sind und kein Ausnahmetatbestand"+
" eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Widerspruch gegen"+
" die Verarbeitung</b></u> (Art. 21 DSGVO): Sie haben das Recht, aus"+
" Gr??nden, die sich aus ihrer besonderen Situation ergeben, jederzeit"+
" gegen die Verarbeitung sie betreffender personenbezogener Daten, die"+
" aufgrund von Art. 6 Abs. 1 Satz 1 lit. e) (??ffentliches Interesse"+
" oder Aus??bung ??ffentlicher Gewalt) oder f) (Wahrung berechtigter"+
" Interessen) DSGVO erfolgt, Widerspruch einzulegen.</p>"+
" </ul>"+
" <p style='margin-left: 2.6cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol>"+
" <ol start='2'>"+
" <h3 class='western'> 2.2 </h3> Wenn Sie dar??ber hinaus Auskunft ??ber"+
" Ihre personenbezogenen Daten w??nschen oder weitergehende Fragen"+
" ??ber die Verarbeitung Ihrer uns ??berlassenen personenbezogenen"+
" Daten haben, sowie eine Korrektur oder L??schung Ihrer Daten"+
" veranlassen m??chten, so wenden Sie sich bitte an die unter Ziffer"+
" <span style='background: #c0c0c0'>3.</span> <span style='text-decoration: none'>&quot;Aus??bung"+
" des </span>Widerspruchs- und Widerrufsrechts<span style='text-decoration: none'>&quot;</span>"+
" angegebene Kontaktadresse."+
" </ol>"+
" </ol>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol start='3'>"+
" <h3 class='western'><a name='_Ref514808556'></a><a name='_Ref493089160'></a>"+
" 3. Aus??bung des Widerspruchs- und Widerrufsrechts</h3>"+
" </ol>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span style='font-weight: normal'>Sie"+
" haben ggf. das Recht, der Verarbeitung Ihrer Daten </span>zu"+
" widersprechen (siehe Ziffer <span style='background: #c0c0c0'>2.1</span>"+
" letztes Aufz??hlungszeichen). Zudem haben Sie das Recht, eine an uns"+
" erteilte Einwilligung mit Wirkung f??r die Zukunft zu widerrufen. In"+
" diesem Fall werden wir die Verarbeitung Ihrer Daten zu diesem Zweck"+
" unverz??glich unterlassen. Einen Widerspruch oder Widerruf k??nnen"+
" Sie jederzeit formlos per Post, Telefax oder Email an uns"+
" ??bermitteln.</p>"+
" <p class='western' style='margin-left: 0.61cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Per"+
" Post:</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Consolinno"+
" Energy GmbH</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Franz-Mayer-Stra??e"+
" 1</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>93053"+
" Regensburg</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span lang='en-US'>Per"+
" Email:</span></p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>info@consolinno.de</p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol start='4'>"+
" <h3 class='western'> 4. Nutzung der Hardware und der mobilen</h3>"+
" Applikation (App)"+
" <ol>"+
" <h3 class='western'><b>4.1 Art und Umfang der Datenverarbeitung:</h3></b>"+
" Bei der Benutzung unserer Hardware und dem Aufruf unserer App ist"+
" es technisch notwendig verschiedene Daten zu verarbeiten,"+
" insbesondere damit die Nutzung und eine fehlerfreie Kommunikation"+
" zwischen Ihrem Endger??t und unserer Cloud m??glich ist. Dabei"+
" werden automatisiert folgende Daten erhoben und in einer"+
" sogenannten Log-Datei protokolliert:"+
" </ol>"+
" </ol>"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol>"+
" <ul>"+
" <li><p style='margin-bottom: 0cm'>Datum und Uhrzeit des Zugriffs</p>"+
" <li><p style='margin-bottom: 0cm'>Hardwaretyp und -version (inkl."+
" Seriennummer)</p>"+
" <li><p style='margin-bottom: 0cm'>Betriebssystemtyp und -version</p>"+
" <li><p style='margin-bottom: 0cm'>IP-Adressen der Ger??te</p>"+
" <li><p style='margin-bottom: 0cm'>Die IP-Adresse Ihres Anschlusses</p>"+
" <li><p style='margin-bottom: 0cm'>Zugangsprovider</p>"+
" <li><p style='margin-bottom: 0cm'>Daten verbundener Mobilger??te"+
" (Hersteller, Typ), Speicherung ausschlie??lich auf der Hardware</p>"+
" <li><p style='margin-bottom: 0cm'>Daten der im Smart Home System"+
" eingebundenen Ger??te (Betriebszust??nde, Betriebsstunden,"+
" Energieverbrauch, Systemstatus, Anlageneinstellungen, Standort der"+
" Anlage, Fehlercodes, Messwerte wie z.B. Temperaturen), Speicherung"+
" ausschlie??lich auf der Hardware</p>"+
" </ul>"+
" </ol>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Wir"+
" erheben diese Daten grunds??tzlich in nicht in personenbezogener"+
" Form. In Ausnahmef??llen l??sst sich die Beziehbarkeit zu einer"+
" nat??rlichen Person nicht vermeiden. F??r die zus??tzliche"+
" Datenverarbeitung im Rahmen des Beta-Tests beachten Sie bitte die"+
" nachfolgende Ziffer 6.</p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol>"+
" <ol start='2'>"+
" <h3 class='western'><b> 4.2 Zweck: </h3></b>Dies geschieht, um die"+
" Nutzung der Hard- und Software ??berhaupt zu erm??glichen,"+
" insbesondere zum Zwecke der systeminternen technischen Verarbeitung"+
" (Verbindungsaufbau), der Systemsicherheit, der technischen"+
" Administration der System- und Netzinfrastruktur sowie zur"+
" Optimierung unseres Angebotes und Produktes. Wir behalten es uns"+
" vor, die Log-Datei nachtr??glich zu ??berpr??fen, wenn aufgrund"+
" konkreter Anhaltspunkte der berechtigte Verdacht einer"+
" rechtswidrigen oder Nutzung besteht."+
" <h3 class='western'><b> 4.3 Rechtsgrundlage:</h3></b> Die vor??bergehende"+
" Verarbeitung der Daten und der Log-Datei erfolgt aus berechtigtem"+
" Interesse zu oben genanntem Zweck gem. Art. 6 Abs. 1 Satz 1 lit. f)"+
" DSGVO sowie zur Erf??llung des Vertrags mit Ihnen, gem. Art. 6 Abs."+
" 1 Satz 1 lit. b) DSGVO."+
" <h3 class='western'><b></h3>4.4 Empf??nger der Daten:</b> Die"+
" anonymisierten Daten werden notwendigerweise an unseren"+
" Hostinganbieter weitergeleitet, bei dem unser Webserver physisch"+
" und technisch verwaltet wird:"+
" </p>"+
" Hostinganbieter: Hetzner Online GmbH,"+
" Industriestr. 25, 91710 Gunzenhausen"+

" <h3 class='western'><b>4.5 Speicherdauer und L??schung:</h3></b> Die"+
" IP-Adresse wird nur bei einem Fernzugriff bei uns gespeichert. Die"+
" Datenspeicherung orientiert sich an den gesetzlichen Regelungen."+
" <h3 class='western'><b>4.6 Widerspruch oder Widerruf:</h3> </b>Diese"+
" Datenverarbeitung ist f??r den Betrieb unserer Hard- und Software"+
" zwingend erforderlich. Daher unterliegt ein etwaiger Widerspruch"+
" einer entsprechenden Interessensabw??gung."+

" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <h3 class='western'><a name='_Ref493089341'></a> 5. Registrierung</h3>"+
" <h3 class='western'><b>5.1 Art und Umfang der Datenverarbeitung:</h3></b>"+
" Sie haben die M??glichkeit, sich in unserer App zu registrieren."+
" Hierzu ist Ihre Einwilligung erforderlich. Um diesen"+
" Registrierungsvorgang erfolgreich durchf??hren zu k??nnen,"+
" ben??tigen wir folgende Daten von Ihnen:"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ul>"+
" <li><p style='margin-bottom: 0cm'>Emailadresse</p>"+
" <li><p style='margin-bottom: 0cm'>Passwort</p>"+
" </ul>"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" Bei der Registrierung wird zudem Ihre IP-Adresse"+
" nebst Datum und Uhrzeit gespeichert. Eine personenbezogene Auswertung"+
" findet grunds??tzlich nicht statt, vorbehaltlich der Teilnahme am"+
" Beta-Test (siehe Ziffer 6). Wir behalten uns jedoch vor, die"+
" gespeicherten Daten nachtr??glich zu ??berpr??fen, wenn aufgrund"+
" konkreter Anhaltspunkte der berechtigte Verdacht einer"+
" missbr??uchlichen Registrierung besteht."+
" <h3 class='western'><b> 5.2 Zweck: </h3></b>Eine Registrierung bietet"+
" Ihnen die M??glichkeit, bestimmte Leistungen in Anspruch zu nehmen"+
" oder Handlungen auszuf??hren, die ohne Registrierung nicht m??glich"+
" sind. Dies geschieht zu folgenden Zwecken:"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ul>"+
" <li><p style='margin-bottom: 0cm'>Betrieb der Hard- und Software</p>"+
" <li><p style='margin-bottom: 0cm'>Benutzung der App</p>"+
" <li><p style='margin-bottom: 0cm'>Nutzung der Cloud</p>"+
" </ul>"+
" <p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" Ihre Daten werden in unserem System hinterlegt,"+
" um Ihnen die M??glichkeit zu bieten, unsere Leistungen in Anspruch zu"+
" nehmen, ohne jedes Mal Ihre Daten erneut eingeben zu m??ssen. Ihre"+
" Emailadresse wird von uns dazu verwendet, um Ihnen Best??tigungsmails"+
" f??r von Ihnen veranlasste ??nderungen Ihrer Profildaten oder zur"+
" Wiederherstellung Ihres Passworts zukommen lassen zu k??nnen sowie um"+
" Sie ??ber notwendige Aktualisierungen der Software zu informieren."+
" Andere Emails senden wir Ihnen nur zu, wenn Sie dies w??nschen und"+
" uns zu diesem Zwecke Ihre Einwilligung erteilt haben. Die Speicherung"+
" Ihrer IP-Adresse nebst Datum und Uhrzeit erfolgt zur"+
" Missbrauchspr??vention."+
" <h3 class='western'><b> 5.3 Rechtsgrundlage:</h3></b> Die Verarbeitung"+
" der Daten erfolgt aufgrund Ihrer Einwilligung gem. Art. 6 Abs. 1"+
" Satz 1 lit. a) DSGVO."+
" <h3 class='western'><b> 5.4 Speicherdauer und L??schung:  </h3></b>Die"+
" Daten werden grunds??tzlich solange gespeichert, bis Sie Ihre"+
" Registrierung k??ndigen und keine gesetzlichen Aufbewahrungsfristen"+
" mehr bestehen. "+
""+
" <h3 class='western'><b> 5.5 Widerspruch oder Widerruf: </h3></b>Sie haben"+
" das Recht, Ihre Registrierung jederzeit zu k??ndigen und Ihre"+
" gespeicherten Daten zu ??ndern sowie Ihre erteilte Einwilligung mit"+
" Wirkung f??r die Zukunft zu widerrufen. Sie k??nnen die ??nderung"+
" Ihres Passworts jederzeit selbst veranlassen. Bei K??ndigung"+
" und/oder Widerruf ist der Zugriff auf die Hard- und Software dann"+
" nicht mehr m??glich."+
" <p class='western' align='left' style='margin-bottom: 0cm; line-height: 100%'>"+
" <br/>"+
" "+
" </p>"+
" <p class='western' style='margin-bottom: 0cm; page-break-before: always'>"+
" <br/>"+
" "+
" </p>"+
" <p style='margin-left: 1.27cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
"     <p style='margin-bottom: 0cm'><b> 6. Erteilte Einwilligungen</b></p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>Soweit"+
" erforderlich haben Sie uns ggf. Einwilligungen zur Verarbeitung Ihrer"+
" personenbezogenen Daten erteilt. In diesem Fall haben wir Ihre"+
" Einwilligung jeweils protokolliert. Wir sind gesetzlich verpflichtet,"+
" den Text der jeweiligen Einwilligung jederzeit f??r Sie abrufbar zu"+
" halten. Selbstverst??ndlich k??nnen Sie uns erteilte Einwilligungen"+
" jederzeit mit Wirkung f??r die Zukunft widerrufen. Wie Sie Ihr"+
" Widerrufsrecht aus??ben k??nnen, erfahren Sie unter Ziffer <span style='background: #c0c0c0'>3.</span>"+
" <span style='text-decoration: none'>&quot;Aus??bung des </span>Widerspruchs-"+
" und Widerrufsrechts<span style='text-decoration: none'>&quot;</span>.</p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><b>Einwilligung"+
" f??r die Registrierung eines Benutzerkontos:</b></p>"+
//" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
//" <font face='MS Gothic, serif'>???</font>"+
//" Ja,</p>"+
//" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>ich"+
" m??chte ein Benutzerkonto er??ffnen, um mich in der App anmelden zu"+
" k??nnen. Zu diesem Zweck willige ich ein, dass meine Daten"+
" (Emailadresse und Passwort) in der Datenbank gespeichert werden."+
" Diese Einwilligung kann ich jederzeit mit Wirkung f??r die Zukunft"+
" widerrufen, indem ich mich an die Adresse in der"+
" <font color='#0000ff'><u><a href='https://hems.consolinno.de/datenschutz/'>https://hems.consolinno.de/datenschutz/</a></u></font>"+
" wende und um L??schung meines Benutzerkontos bitte. Um diesen Vorgang"+
" zu protokollieren, wird meine IP-Adresse, sowie Datum und Uhrzeit der"+
" Registrierung in einer Datenbank gespeichert und erst wieder"+
" gel??scht, wenn ich die Einwilligung widerrufe, sofern eine"+
" weitergehende Speicherung nicht rechtlich erforderlich ist. Die AGB"+
" unter <font color='#0000ff'><u><a href='https://hems.consolinno.de/agb'>https://hems.consolinno.de/agb</a>/</u></font>"+
" habe ich gelesen und verstanden.</p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <h3 class='western'><br/>"+
" "+
" </h3>"+
" <p style='margin-bottom: 0cm'><b> 7. Elektronische Post (Email) /"+
" Kontaktaufnahme</b></p>"+
" <p style='margin-bottom: 0cm'> 7.1 Informationen, die Sie"+
" unverschl??sselt per Elektronischer Post (Email) an uns senden,"+
" k??nnen m??glicherweise auf dem ??bertragungsweg von Dritten"+
" gelesen werden. Wir k??nnen in der Regel auch Ihre Identit??t nicht"+
" ??berpr??fen und wissen nicht, wer wirklicher Inhaber einer"+
" Emailadresse ist. Eine rechtssichere Kommunikation durch einfache"+
" Email ist daher nicht gew??hrleistet. Wie viele Anbieter setzen wir"+
" Filter gegen unerw??nschte Werbung (???SPAM-Filter???) ein, die in"+
" einigen F??llen auch normale Emails f??lschlicherweise automatisch"+
" als unerw??nschte Werbung einordnen und l??schen. Emails, die"+
" sch??digende Programme (???Viren???) enthalten, werden von uns in"+
" jedem Fall automatisch gel??scht. Wenn Sie schutzw??rdige"+
" Nachrichten an uns senden wollen, empfehlen wir, die Nachricht auf"+
" konventionellem Postwege an uns zu senden. "+
" </p>"+
" <p style='margin-bottom: 0cm'><b> 7.2 Art und Umfang der"+
" Datenverarbeitung: </b>Im Falle der Kontaktaufnahme mit uns werden"+
" Ihre Daten, Ihre IP-Adresse sowie Datum und Uhrzeit gespeichert.</p>"+
" <p style='margin-bottom: 0cm'><b> 7.3 Zweck: </b>Dies geschieht"+
" insbesondere zu Kommunikationszwecken und zum Schutz unserer"+
" Systeme gegen Missbrauch.</p>"+
" <p style='margin-bottom: 0cm'><b> 7.4 Rechtsgrundlage: </b>Die"+
" Verarbeitung der Daten erfolgt aus berechtigtem Interesse zu oben"+
" genanntem Zweck gem. Art. 6 Abs. 1 Satz 1 lit. f) DSGVO.</p>"+
" <p style='margin-bottom: 0cm'><b> 7.5 Speicherdauer und L??schung:"+
" </b>Die Daten werden erst dann gel??scht, falls keine vertraglichen"+
" oder gesetzlichen Verpflichtungen einer L??schung entgegenstehen.</p>"+
" <p style='margin-bottom: 0cm'><b> 7.6 Widerspruch oder Widerruf:</b>"+
" Sie k??nnen der Kontaktaufnahme per Email jederzeit widersprechen."+
" In diesem Fall kann keine weitere Korrespondenz via Email"+
" stattfinden.</p>"+
" <p class='western' align='left' style='margin-bottom: 0cm; line-height: 100%'>"+
" <br/>"+
" "+
" </p>"+
" <p class='western' style='margin-bottom: 0cm; page-break-before: always'>"+
" <br/>"+
" "+
" </p>"+
" <li><p style='margin-bottom: 0cm'><b>G??ltigkeit</b></p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>Wir"+
" sind stets bem??ht, unsere Hard- und Software weiterzuentwickeln und"+
" neue Technologien einzusetzen. Daher kann es notwendig werden, diese"+
" Datenschutzerkl??rung zu ??ndern, bzw. anzupassen. Wir behalten uns"+
" daher das Recht vor, diese Erkl??rung jederzeit mit Wirkung f??r die"+
" Zukunft zu ??ndern. Bitte besuchen Sie daher diese Seite regelm????ig"+
" und lesen Sie die jeweils aktuelle Datenschutzerkl??rung von Zeit zu"+
" Zeit erneut durch.</p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <div id='sdfootnote1'><p class='sdfootnote-western'><a class='sdfootnotesym' name='sdfootnote1sym' href='#sdfootnote1anc'>1</a><font size='1' style='font-size: 8pt'>"+
" Aus Gr??nden der besseren Lesbarkeit wird auf die gleichzeitige"+
" Verwendung der Sprachformen m??nnlich, weiblich und divers (m/w/d)"+
" verzichtet. S??mtliche Personenbezeichnungen gelten gleicherma??en"+
" f??r alle Geschlechter.</font></p>"+
" </div>"+
" </body>"+
" </html>"
                        }
                }


                RowLayout{
                    CheckBox{
                        id: accountCheckbox
                        Layout.alignment: Qt.AlignHCenter

                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Yes I agree to open a user account, according to part 6 ")
                    }
                }


                RowLayout{
                    CheckBox {
                        id: policyCheckbox
                        Layout.alignment: Qt.AlignHCenter
                    }


                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr('I confirm that I have read the the agreement and I am accepting it.')
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: policyCheckbox.checked && accountCheckbox.checked ? qsTr('next') : qsTr('cancel')
                    //color: policyCheckbox.checked ? Style.accentColor : Style.yellow
                    Layout.preferredWidth: 200
                    background: Rectangle{
                        color: policyCheckbox.checked && accountCheckbox.checked ? '#87BD26' : 'grey'
                        radius: 4
                    }


                    onClicked: {
                        if (policyCheckbox.checked && accountCheckbox.checked) {
                            privacyPolicyPage.next()
                        } else {
                            Qt.quit()
                        }
                    }
                }
            }
        }

    }

    Component {
        id: connectionInfo
        ConsolinnoWizardPageBase {
            id: connectionInfoPage

            showNextButton: false
            showBackButton: false
            background: Item {}
            onNext: pageStack.push(findLeafletComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
                width: Math.min(parent.width, 450)

                Label {
                    Layout.fillWidth: true
                    text: qsTr('Establishing a connection')
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font: Style.bigFont
                }

                ColumnLayout{
                    Layout.fillWidth: true
                    Label{
                        id: pos
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        text: qsTr("There are two ways to connect your device (smartphone/ PC) with the Leaflet:")

                    }

                    ColumnLayout{
                        Layout.fillWidth: true
                        Layout.topMargin: 30
                        spacing: 1
                        Label{
                            id: firstOption
                            Layout.fillWidth: true
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            wrapMode: Text.WordWrap
                            font.bold: true

                            text: qsTr("1. Connection via the local network")

                        }
                        Label{
                            id: optionOne
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            Layout.topMargin: 1
                            text: qsTr("Connect the device to the same network where the Leaflet is connected.")

                        }


                    }

                    ColumnLayout{
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 1
                        Label{
                            id: secondOption
                            wrapMode: Text.WordWrap
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            Layout.fillWidth: true
                            font.bold: true

                            text: qsTr("2. Direct connection with LAN cable")

                        }
                        Label{
                            id: optionTwo
                            Layout.fillWidth: true
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            wrapMode: Text.WordWrap
                            Layout.topMargin: 1
                            text: qsTr("Connect your device with LAN cable to the 3rd Ethernet slot (LAN 3). Smartphones can also be connected to the Leaflet with LAN cable using an appropriate LAN adapter.")

                        }


                    }




                }


                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('next')
                    //color: Style.accentColor
                    Layout.preferredWidth: 200
                    background: Rectangle{
                        color: Style.accentColor
                        radius: 4
                    }

                    onClicked: {
                        connectionInfoPage.next()
                    }
                }
            }
        }
    }


    Component {
        id: findLeafletComponent

        ConsolinnoWizardPageBase {
            id: findLeafletPage
            onBack: pageStack.pop()
            nextButtonText: qsTr('Manual connection')


            onNext: pageStack.push(manualConnectionComponent)
            background: Item{}

            Timer {
                id: timeoutTimer
                interval: 15000
                running: hostsProxy.count == 0
                onTriggered: pageStack.pop()
            }

            content: ColumnLayout {
                anchors.fill: parent


                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: hostsProxy.count === 0
                          ? qsTr('Searching for your Leaflet...')
                          : qsTr("We've detected multiple Leaflets in your network. Please select the one you'd like to set up.")
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.height/3
                    clip: true
                    model: NymeaHostsFilterModel {
                        id: hostsProxy
                        discovery: nymeaDiscovery
                        showUnreachableBearers: false
                        jsonRpcClient: engine.jsonRpcClient
                        showUnreachableHosts: false
                        /*
                        onCountChanged: {
                            if (count === 1) {
                                engine.jsonRpcClient.connectToHost(hostsProxy.get(0))
                            }
                        }*/
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        visible: hostsProxy.count == 0
                        spacing: Style.margins
                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.margins: Style.margins
                            text: qsTr('Please wait while your Leaflet is being discovered.')
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


                    delegate: NymeaSwipeDelegate {
                        id: nymeaHostDelegate
                        width: parent.width
                        property var nymeaHost: hostsProxy.get(index)
                        property string defaultConnectionIndex: {
                            var bestIndex = -1
                            var bestPriority = 0;
                            for (var i = 0; i < nymeaHost.connections.count; i++) {
                                var connection = nymeaHost.connections.get(i);
                                if (bestIndex === -1 || connection.priority > bestPriority) {
                                    bestIndex = i;
                                    bestPriority = connection.priority;
                                }
                            }
                            return bestIndex;
                        }
                        iconName: {
                            switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return '/ui/images/connections/network-wired.svg'
                                }
                                return '/ui/images/connections/network-wifi.svg';
                            case Connection.BearerTypeBluetooth:
                                return '/ui/images/connections/bluetooth.svg';
                            case Connection.BearerTypeCloud:
                                return '/ui/images/connections/cloud.svg'
                            case Connection.BearerTypeLoopback:
                                return 'qrc:/styles/%1/logo.svg'.arg(styleController.currentStyle)
                            }
                            return ''
                        }
                        text: model.name
                        subText: nymeaHost.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? '/ui/images/connections/network-secure.svg' : ''
                        secondaryIconName: !isOnline ? '/ui/images/connections/cloud-error.svg' : ''
                        secondaryIconColor: 'red'

                        onClicked: {


                            engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr('Info'),
                                icon: Qt.resolvedUrl('/ui/images/info.svg'),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var connectionInfoDialog = Qt.createComponent('/ui/components/ConnectionInfoDialog.qml')
                                    var popup = connectionInfoDialog.createObject(app,{nymeaHost: nymeaHost})
                                    console.warn('::', connectionInfoDialog.errorString())
                                    popup.open()
                                }
                            }
                        ]
                    }
                }

//                Label{
//                    Layout.fillHeight: true
//                    Layout.fillWidth: true
//                    Layout.margins: Style.margins
//                    //horizontalAlignment: Text.AlignHCenter
//                    wrapMode: Text.WordWrap
//                    text: qsTr('You have to authenticate yourself to the Leaflet. For further information look at the manual for commissioning.')

//                }


            }
        }
    }

    Component {
        id: manualConnectionComponent
        ConsolinnoWizardPageBase {
//            title: qsTr('Manual connection')
//            text: qsTr('Please enter the connection information for your nymea system')
            onBack: pageStack.pop()
            background: Item {}
            onNext: {
                var rpcUrl
                var hostAddress
                var port

                // Set default to placeholder
                if (addressTextInput.text === '') {
                    hostAddress = addressTextInput.placeholderText
                } else {
                    hostAddress = addressTextInput.text
                }

                if (portTextInput.text === '') {
                    port = portTextInput.placeholderText
                } else {
                    port = portTextInput.text
                }

                if (connectionTypeComboBox.currentIndex == 0) {
                    if (secureCheckBox.checked) {
                        rpcUrl = 'nymeas://' + hostAddress + ':' + port
                    } else {
                        rpcUrl = 'nymea://' + hostAddress + ':' + port
                    }
                } else if (connectionTypeComboBox.currentIndex == 1) {
                    if (secureCheckBox.checked) {
                        rpcUrl = 'wss://' + hostAddress + ':' + port
                    } else {
                        rpcUrl = 'ws://' + hostAddress + ':' + port
                    }
                }

                print('Try to connect ', rpcUrl)
                var host = nymeaDiscovery.nymeaHosts.createWanHost('Manual connection', rpcUrl);
                engine.jsonRpcClient.connectToHost(host)
            }

            content: ColumnLayout {


                anchors.fill: parent
                anchors.margins: Style.margins
                GridLayout {
                    columns: 2

                    Label {
                        text: qsTr('Protocol')
                    }

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr('TCP'), qsTr('Websocket') ]
                    }

                    Label { text: qsTr('Address:') }
                    TextField {
                        id: addressTextInput
                        objectName: 'addressTextInput'
                        Layout.fillWidth: true
                        placeholderText: '127.0.0.1'
                    }

                    Label { text: qsTr('Port:') }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0 ? '2222' : '4444'
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr('Encrypted connection:')
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }
            }
        }
    }
}
