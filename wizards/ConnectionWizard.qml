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
                    text: qsTr("(1) Consolinno Energy GmbH hat eine Software entwickelt, welche als Applikation auf Android und IOS-Systemen benutzt werden kann. Die Software verbindet sich mit einem Energy Management Systems genannt Leaflet HEMS. Das hat dann die Aufgabe in Verbindung mit einer Photovoltaikanlage den Eigenverbrauch der PV-Energie zu maximieren. Parallel ist die Funktion Black-out Schutz integriert. Damit wird der Ladestrom einer Ladeeinrichtung dynamisch begrenzt. Es kommt nicht zum Auslösen der Sicherung.")

                }






                Text{
                    id: allgemeinText2
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Die Software ermöglicht es, durch die Steuerung einer E-Ladeeinrichtung, einer Wärmepumpe, Hausgeräte (Waschmaschine, Trockner, Spülmaschine) und dem Einbinden einer Batterie den Eigenbedarf der erzeugten PV-Energie signifikant zu steigern.")

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
                    text: qsTr("Diese allgemeinen Lizenzbestimmungen gelten für sämtliche Lizenzverträge mit dem Kunden über die Module der Software und dem HEMS Produkt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Die Software wird von der Consolinno Energy GmbH kostenfrei Kunden vom HEMS über Appstores angeboten.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die Kunden sind für das ordnungsgemäße Installieren der Hard- und Software verantwortlich.")

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
                    text: qsTr("(1) Consolinno Energy GmbH gewährt dem Kunden das ausschließliche Recht die in der Vereinbarung näher beschriebene Software innerhalb Deutschlands zu nutzen. Es wird ein nicht-ausschließliches und nicht-übertragbares Nutzungsrecht an der Software eingeräumt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Soweit dies für die vertragsgemäße Nutzung erforderlich ist, darf die Software vervielfältigt werden.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Über die Appstores kann der Kunde mit dem jeweiligen Betriebssystem das Programm laden und installieren")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Im Übrigen ist der Kunde zu einer Vervielfältigung oder Überlassung an Dritte nicht berechtigt, soweit gesetzlich nicht anderes bestimmt.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Der Kunde ist nicht berechtigt, die Software zu verändern und zu bearbeiten, es sei denn, es handelt sich bei der Änderung bzw. Bearbeitung um eine für die vertragsgemäße Nutzung der Software erforderliche Beseitigung eines Mangels, mit welcher sich die Consolinno Energy GmbH in Verzug befindet.")

                }


                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("3.Lizenzgebühr")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Der Kunde hat mit dem Erwerb des HEMS-Gerätes die Software kostenfrei von den APP Stores geladen und kann diese benutzen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Im Rahmen der Weiterentwicklung können Softwaremodule auch für eine unbefristete Nutzungsdauer käuflich erworben werden.")

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
                    text: qsTr("(1) Consolinno Energy GmbH liefert die Software an den Kunden über den Appstore von Apple oder Google aus.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Neben der Software wird Consolinno Energy GmbH dem Kunden eine Installationsanleitung des Gerätes HEMS sowie eine Dokumentation zum Download anbieten.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("3) Consolinno Energy GmbH schuldet keine Installation der Software auf den Systemen des Kunden; für diese ist der Kunde allein ver-antwortlich.")

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
                    text: qsTr("(1) Consolinno Energy GmbH ist zur Aufrechterhaltung der vertraglich vereinbarten Beschaffenheit der Software während der Vertragslaufzeit ('Instandhaltung') verpflichtet. Die vertraglich geschuldete Beschaffenheit der Software bestimmt sich nach der zugesagten Funktion des HEMS Produktes. Up Dates erfolgen über eine Internetverbindung.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Consolinno Energy GmbH ist zu einer Änderung, Anpassung und Weiterentwicklung der Software nur dann verpflichtet, wenn das mit dem Kunden gesondert vereinbart ist. Ohne eine solche gesonderte Vereinbarung ist die Consolinno Energy GmbH nicht zu einer Weiterentwicklung der Software verpflichtet.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("6.Gewährleistung")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Sollte dem Kunden Mängel an der Software, am Gerät oder an der Dokumentation feststellen, so hat der Kunde das der Consolinno Energy GmbH mitzuteilen. Das kann zum Beispiel per Mail erfolgen.")

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
                    text: qsTr("(3) Consolinno Energy GmbH wird die angezeigten Mängel an der Software und an der Dokumentation innerhalb einer angemessenen Frist zu beheben. Im Rahmen der Mängelbeseitigung hat Consolinno Energy GmbH ein Wahlrecht zwischen Nachbesserung und Ersatzlieferung. Die Kosten der Mängelbeseitigung trägt Consolinno Energy GmbH. Kosten für Ausfall, entgangener Gewinn, Ein- und Ausbaukosten oder ähnliches werden nicht erstattet.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Schlägt die hierin geschuldete Mängelbeseitigung fehl, ist die Kunde zur außerordentlichen Kündigung des betreffenden Vertrages gemäß § 543 Abs. 2 S. 1 Nr. 1 BGB berechtigt.")

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
                    text: qsTr("(1) Der Lizenzgeber haftet unbeschränkt:

· bei Arglist, Vorsatz oder grober Fahrlässigkeit;

· im Rahmen einer von ihm ausdrücklich übernommenen Garantie;

· für Schäden aus der Verletzung des Lebens, des Körpers oder der Gesundheit;

· nach den Vorschriften des Produkthaftungsgesetzes")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Im Übrigen ist eine Haftung der Consolinno Energy GmbH für direkte und indirekte Schäden ausgeschlossen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Open Source

Open Source Module sind in der APP und in der Gerätesoftware enthalten. Es gelten für diese Module die entsprechende Garantie und Haftungsbedingungen. Sollte das nicht möglich sein, dann gilt die Regelung im jeweiligen Anwenderland.")

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
                    text: qsTr("(2) Das Recht beider Parteien zur jederzeitigen außerordentlichen und fristlosen Kündigung aus wichtigem Grund bleibt unberührt. Ein wichtiger Grund liegt insbesondere vor, wenn der Lizenzgeber oder die Lizenznehmerin vorsätzlich oder fahrlässig gegen eine wesentliche Pflicht aus diesen Lizenzbestimmungen verstößt und deswegen der kündigenden Partei das Festhalten am Lizenzvertrag nicht mehr zumutbar ist. Der Lizenzgeber ist hiernach insbesondere zur außerordentlichen und fristlosen Kündigung des Lizenzvertrages berechtigt, wenn die Lizenznehmerin die ihr eingeräumten Nutzungsbefugnisse überschreitet und ihre Verletzungshandlungen nicht innerhalb einer angemessenen Frist abstellt, wenn der Lizenzgeber diese zuvor zur Unterlassung dieser Verletzungshandlungen abgemahnt hat.")

                }


                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die Kündigung des Lizenzvertrages bedarf der Schriftform.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Consolinno Energy GmbH kann die Pflege des Programmes ohne nennen von Gründen einstellen")

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
                    text: qsTr("(1) Sollte eine dieser Lizenzbestimmungen oder eine später in diesen Lizenzvertrag aufgenommene Bestimmung ganz oder teilweise nichtig oder undurchführbar sein oder werden oder sollte sich eine Lücke in diesen Lizenzbestimmungen herausstellen, wird dadurch die Wirksamkeit der übrigen Bestimmungen nicht berührt (Erhaltung). Es ist der ausdrückliche Wille der Parteien, hierdurch die Wirksamkeit der übrigen Bestimmungen unter allen Umständen aufrechtzuerhalten und damit § 139 BGB insgesamt abzubedingen. Anstelle der nichtigen oder undurchführbaren Bestimmung oder zur Ausfüllung der Lücke gilt mit Rückwirkung diejenige wirksame und durchführbare Regelung als bestimmt, die rechtlich und wirtschaftlich dem am nächsten kommt, was die Parteien gewollt haben oder nach dem Sinn und Zweck des Lizenzvertrages gewollt hätten, wenn sie diesen Punkt bei Abschluss dieser Vereinbarung bzw. bei Aufnahme der Bestimmung bedacht hätten; beruht die Nichtigkeit einer Bestimmung auf einem darin festgelegten Maß der Leistung oder der Zeit (Frist oder Termin), so gilt die Bestimmung mit einem dem ursprünglichen Maß am nächsten kommenden rechtlich zulässigen Maß als vereinbart (Ersetzungsfiktion). Ist die Ersetzungsfiktion nicht möglich, ist anstelle der nichtigen oder undurchführbaren Bestimmung oder zur Schließung der Lücke eine Bestimmung bzw. Regelung nach inhaltlicher Maßgabe des vorstehenden Satzes zu treffen (Ersetzungsverpflichtung). Betrifft die Nichtigkeit oder Lücke eine beurkundungspflichtige Bestimmung, so ist die Regelung bzw. die Bestimmung in notariell beurkundeter Form zu vereinbaren.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Änderungen und Ergänzungen des betreffenden Lizenzvertrages einschließlich dieser Klausel bedürfen der Schriftform, soweit nicht etwas anderes bestimmt ist")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Die Parteien dürfen den Lizenzvertrag sowie Rechte und Pflichten aus dem Lizenzvertrag nur mit vorheriger schriftlicher Zustimmung der jeweils anderen Partei auf einen Dritten übertragen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) Die Geltung der Allgemeinen Geschäftsbedingungen der Lizenznehmerin werden ausdrücklich ausgeschlossen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(5) Ausschließlicher Gerichtsstand für alle Streitigkeiten aus oder im Zusammenhang mit dem Lizenzvertrag ist der Sitz des Lizenzgebers, Regensburg. Der Lizenzgeber bleibt berechtigt, am allgemeinen Gerichtsstand der Lizenznehmerin zu klagen.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Anschrift des Lizenzgebers
Consolinno Energy GmbH, Franz-Mayer-Straße 1, 93053 Regensburg")

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
" <meta name='changedby' content='Böhm, Patricia'/>"+
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
" Bundesrepublik Deutschland und der Europäischen Union (EU). Dabei "+
" hat der Schutz Ihrer persönlichen Informationen höchste Priorität. "+
" Im Folgenden erfahren Sie, welche Daten wir in welcher Form aufgrund "+
" welcher Rechtsgrundlage zu welchem Zweck wie lange verarbeiten, "+
" inwieweit Ihnen ein Widerspruchsrecht zusteht und wie sie dieses "+
" ausüben können. Sollte Ihre Einwilligung notwendig sein, so wird "+
" Ihnen dies an entsprechender Stelle angezeigt und Sie haben die "+
" Möglichkeit, diese zu erteilen oder von einer Erteilung abzusehen. "+
" Selbstverständlich haben Sie auch nach Erteilung Ihrer Einwilligung "+
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
" durch den Geschäftsführer</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Franz-Mayer-Straße"+
" 1</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>93053"+
" Regensburg</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Der "+
" zuständige betriebliche Datenschutzbeauftragte (bDSB) ist:</p>"+
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
" Wir möchten Sie an dieser Stelle auf das <u>Recht zur Beschwerde bei"+
" der Aufsichtsbehörde</u> gemäß Art. 77 DSGVO hinweisen. Demnach"+
" hat jede betroffene Person unbeschadet eines anderweitigen"+
" Rechtsbehelfs das Recht auf Beschwerde bei der Aufsichtsbehörde,"+
" wenn sie der Ansicht ist, dass die Verarbeitung der sie betreffenden"+
" personenbezogenen Daten gegen die Datenschutz-Grundverordnung"+
" verstößt.</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Die "+
" Kontaktdaten der für den Verantwortlichen zuständigen"+
" Aufsichtsbehörde lauten:</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><font color='#000000'><span style='background: #ffffff'>Bayerisches"+
" Landesamt für Datenschutzaufsicht</span></font></p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Promenade"+
" 18</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>91522"+
" Ansbach</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol start='2'>"+
" <h3 class='western'> 2. Information über Ihre Rechte als betroffene"+
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
" Auskunft darüber zu verlangen, ob Sie betreffende personenbezogene"+
" Daten verarbeitet werden. Ist dies der Fall, so haben Sie das Recht"+
" auf Auskunft über diese personenbezogenen Daten und damit im"+
" Zusammenhang stehende weitergehende Informationen.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Berichtigung</b></u>"+
" (Art. 16 DSGVO): Sie haben das Recht, von dem Verantwortlichen"+
" unverzüglich die Berichtigung Sie betreffender unrichtiger"+
" personenbezogener Daten zu verlangen. Unter Berücksichtigung der"+
" Zwecke der Verarbeitung haben Sie das Recht, die Vervollständigung"+
" unvollständiger personenbezogener Daten – auch mittels einer"+
" ergänzenden Erklärung – zu verlangen.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Löschung</b></u>"+
" (Art. 17 DSGVO): Sie haben das Recht, von dem Verantwortlichen zu"+
" verlangen, dass Sie betreffende personenbezogene Daten unverzüglich"+
" gelöscht werden, und der Verantwortliche ist verpﬂichtet,"+
" personenbezogene Daten unverzüglich zu löschen, sofern einer der"+
" Gründe des Art. 17 Abs. 1 DSGVO zutrifft und kein"+
" Ausnahmetatbestand eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Einschränkung der"+
" Verarbeitung</b></u> (Art. 18 DSGVO): Sie haben das Recht, von dem"+
" Verantwortlichen die Einschränkung der Verarbeitung (ehemals:"+
" Sperre) Ihrer personenbezogenen Daten zu verlangen, wenn eine der"+
" Voraussetzungen des Art. 18 Abs. 1 DSGVO gegeben ist und kein"+
" Ausnahmetatbestand eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Datenübertragbarkeit</b></u>"+
" (Art. 20 DSGVO): Sie haben das Recht, die Sie betreffenden"+
" personenbezogenen Daten, die sie einem Verantwortlichen"+
" bereitgestellt haben, in einem strukturierten, gängigen und"+
" maschinenlesbaren Format zu erhalten, und sie haben das Recht, diese"+
" Daten einem anderen Verantwortlichen ohne Behinderung durch den"+
" Verantwortlichen, dem die personenbezogenen Daten bereitgestellt"+
" wurden, zu übermitteln, sofern die weiteren Voraussetzungen des"+
" Art. 20 Abs. 1 DSGVO gegeben sind und kein Ausnahmetatbestand"+
" eingreift.</p>"+
" <li><p style='margin-bottom: 0cm'>Recht auf <u><b>Widerspruch gegen"+
" die Verarbeitung</b></u> (Art. 21 DSGVO): Sie haben das Recht, aus"+
" Gründen, die sich aus ihrer besonderen Situation ergeben, jederzeit"+
" gegen die Verarbeitung sie betreffender personenbezogener Daten, die"+
" aufgrund von Art. 6 Abs. 1 Satz 1 lit. e) (öffentliches Interesse"+
" oder Ausübung öffentlicher Gewalt) oder f) (Wahrung berechtigter"+
" Interessen) DSGVO erfolgt, Widerspruch einzulegen.</p>"+
" </ul>"+
" <p style='margin-left: 2.6cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol>"+
" <ol start='2'>"+
" <h3 class='western'> 2.2 </h3> Wenn Sie darüber hinaus Auskunft über"+
" Ihre personenbezogenen Daten wünschen oder weitergehende Fragen"+
" über die Verarbeitung Ihrer uns überlassenen personenbezogenen"+
" Daten haben, sowie eine Korrektur oder Löschung Ihrer Daten"+
" veranlassen möchten, so wenden Sie sich bitte an die unter Ziffer"+
" <span style='background: #c0c0c0'>3.</span> <span style='text-decoration: none'>&quot;Ausübung"+
" des </span>Widerspruchs- und Widerrufsrechts<span style='text-decoration: none'>&quot;</span>"+
" angegebene Kontaktadresse."+
" </ol>"+
" </ol>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol start='3'>"+
" <h3 class='western'><a name='_Ref514808556'></a><a name='_Ref493089160'></a>"+
" 3. Ausübung des Widerspruchs- und Widerrufsrechts</h3>"+
" </ol>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span style='font-weight: normal'>Sie"+
" haben ggf. das Recht, der Verarbeitung Ihrer Daten </span>zu"+
" widersprechen (siehe Ziffer <span style='background: #c0c0c0'>2.1</span>"+
" letztes Aufzählungszeichen). Zudem haben Sie das Recht, eine an uns"+
" erteilte Einwilligung mit Wirkung für die Zukunft zu widerrufen. In"+
" diesem Fall werden wir die Verarbeitung Ihrer Daten zu diesem Zweck"+
" unverzüglich unterlassen. Einen Widerspruch oder Widerruf können"+
" Sie jederzeit formlos per Post, Telefax oder Email an uns"+
" übermitteln.</p>"+
" <p class='western' style='margin-left: 0.61cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Per"+
" Post:</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Consolinno"+
" Energy GmbH</p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Franz-Mayer-Straße"+
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
" zwischen Ihrem Endgerät und unserer Cloud möglich ist. Dabei"+
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
" <li><p style='margin-bottom: 0cm'>IP-Adressen der Geräte</p>"+
" <li><p style='margin-bottom: 0cm'>Die IP-Adresse Ihres Anschlusses</p>"+
" <li><p style='margin-bottom: 0cm'>Zugangsprovider</p>"+
" <li><p style='margin-bottom: 0cm'>Daten verbundener Mobilgeräte"+
" (Hersteller, Typ), Speicherung ausschließlich auf der Hardware</p>"+
" <li><p style='margin-bottom: 0cm'>Daten der im Smart Home System"+
" eingebundenen Geräte (Betriebszustände, Betriebsstunden,"+
" Energieverbrauch, Systemstatus, Anlageneinstellungen, Standort der"+
" Anlage, Fehlercodes, Messwerte wie z.B. Temperaturen), Speicherung"+
" ausschließlich auf der Hardware</p>"+
" </ul>"+
" </ol>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Wir"+
" erheben diese Daten grundsätzlich in nicht in personenbezogener"+
" Form. In Ausnahmefällen lässt sich die Beziehbarkeit zu einer"+
" natürlichen Person nicht vermeiden. Für die zusätzliche"+
" Datenverarbeitung im Rahmen des Beta-Tests beachten Sie bitte die"+
" nachfolgende Ziffer 6.</p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <ol>"+
" <ol start='2'>"+
" <h3 class='western'><b> 4.2 Zweck: </h3></b>Dies geschieht, um die"+
" Nutzung der Hard- und Software überhaupt zu ermöglichen,"+
" insbesondere zum Zwecke der systeminternen technischen Verarbeitung"+
" (Verbindungsaufbau), der Systemsicherheit, der technischen"+
" Administration der System- und Netzinfrastruktur sowie zur"+
" Optimierung unseres Angebotes und Produktes. Wir behalten es uns"+
" vor, die Log-Datei nachträglich zu überprüfen, wenn aufgrund"+
" konkreter Anhaltspunkte der berechtigte Verdacht einer"+
" rechtswidrigen oder Nutzung besteht."+
" <h3 class='western'><b> 4.3 Rechtsgrundlage:</h3></b> Die vorübergehende"+
" Verarbeitung der Daten und der Log-Datei erfolgt aus berechtigtem"+
" Interesse zu oben genanntem Zweck gem. Art. 6 Abs. 1 Satz 1 lit. f)"+
" DSGVO sowie zur Erfüllung des Vertrags mit Ihnen, gem. Art. 6 Abs."+
" 1 Satz 1 lit. b) DSGVO."+
" <h3 class='western'><b></h3>4.4 Empfänger der Daten:</b> Die"+
" anonymisierten Daten werden notwendigerweise an unseren"+
" Hostinganbieter weitergeleitet, bei dem unser Webserver physisch"+
" und technisch verwaltet wird:"+
" </p>"+
" Hostinganbieter: Hetzner Online GmbH,"+
" Industriestr. 25, 91710 Gunzenhausen"+

" <h3 class='western'><b>4.5 Speicherdauer und Löschung:</h3></b> Die"+
" IP-Adresse wird nur bei einem Fernzugriff bei uns gespeichert. Die"+
" Datenspeicherung orientiert sich an den gesetzlichen Regelungen."+
" <h3 class='western'><b>4.6 Widerspruch oder Widerruf:</h3> </b>Diese"+
" Datenverarbeitung ist für den Betrieb unserer Hard- und Software"+
" zwingend erforderlich. Daher unterliegt ein etwaiger Widerspruch"+
" einer entsprechenden Interessensabwägung."+

" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <h3 class='western'><a name='_Ref493089341'></a> 5. Registrierung</h3>"+
" <h3 class='western'><b>5.1 Art und Umfang der Datenverarbeitung:</h3></b>"+
" Sie haben die Möglichkeit, sich in unserer App zu registrieren."+
" Hierzu ist Ihre Einwilligung erforderlich. Um diesen"+
" Registrierungsvorgang erfolgreich durchführen zu können,"+
" benötigen wir folgende Daten von Ihnen:"+
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
" findet grundsätzlich nicht statt, vorbehaltlich der Teilnahme am"+
" Beta-Test (siehe Ziffer 6). Wir behalten uns jedoch vor, die"+
" gespeicherten Daten nachträglich zu überprüfen, wenn aufgrund"+
" konkreter Anhaltspunkte der berechtigte Verdacht einer"+
" missbräuchlichen Registrierung besteht."+
" <h3 class='western'><b> 5.2 Zweck: </h3></b>Eine Registrierung bietet"+
" Ihnen die Möglichkeit, bestimmte Leistungen in Anspruch zu nehmen"+
" oder Handlungen auszuführen, die ohne Registrierung nicht möglich"+
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
" um Ihnen die Möglichkeit zu bieten, unsere Leistungen in Anspruch zu"+
" nehmen, ohne jedes Mal Ihre Daten erneut eingeben zu müssen. Ihre"+
" Emailadresse wird von uns dazu verwendet, um Ihnen Bestätigungsmails"+
" für von Ihnen veranlasste Änderungen Ihrer Profildaten oder zur"+
" Wiederherstellung Ihres Passworts zukommen lassen zu können sowie um"+
" Sie über notwendige Aktualisierungen der Software zu informieren."+
" Andere Emails senden wir Ihnen nur zu, wenn Sie dies wünschen und"+
" uns zu diesem Zwecke Ihre Einwilligung erteilt haben. Die Speicherung"+
" Ihrer IP-Adresse nebst Datum und Uhrzeit erfolgt zur"+
" Missbrauchsprävention."+
" <h3 class='western'><b> 5.3 Rechtsgrundlage:</h3></b> Die Verarbeitung"+
" der Daten erfolgt aufgrund Ihrer Einwilligung gem. Art. 6 Abs. 1"+
" Satz 1 lit. a) DSGVO."+
" <h3 class='western'><b> 5.4 Speicherdauer und Löschung:  </h3></b>Die"+
" Daten werden grundsätzlich solange gespeichert, bis Sie Ihre"+
" Registrierung kündigen und keine gesetzlichen Aufbewahrungsfristen"+
" mehr bestehen. "+
""+
" <h3 class='western'><b> 5.5 Widerspruch oder Widerruf: </h3></b>Sie haben"+
" das Recht, Ihre Registrierung jederzeit zu kündigen und Ihre"+
" gespeicherten Daten zu ändern sowie Ihre erteilte Einwilligung mit"+
" Wirkung für die Zukunft zu widerrufen. Sie können die Änderung"+
" Ihres Passworts jederzeit selbst veranlassen. Bei Kündigung"+
" und/oder Widerruf ist der Zugriff auf die Hard- und Software dann"+
" nicht mehr möglich."+
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
" den Text der jeweiligen Einwilligung jederzeit für Sie abrufbar zu"+
" halten. Selbstverständlich können Sie uns erteilte Einwilligungen"+
" jederzeit mit Wirkung für die Zukunft widerrufen. Wie Sie Ihr"+
" Widerrufsrecht ausüben können, erfahren Sie unter Ziffer <span style='background: #c0c0c0'>3.</span>"+
" <span style='text-decoration: none'>&quot;Ausübung des </span>Widerspruchs-"+
" und Widerrufsrechts<span style='text-decoration: none'>&quot;</span>.</p>"+
" <p class='western' style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><b>Einwilligung"+
" für die Registrierung eines Benutzerkontos:</b></p>"+
//" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
//" <font face='MS Gothic, serif'>☐</font>"+
//" Ja,</p>"+
//" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>ich"+
" möchte ein Benutzerkonto eröffnen, um mich in der App anmelden zu"+
" können. Zu diesem Zweck willige ich ein, dass meine Daten"+
" (Emailadresse und Passwort) in der Datenbank gespeichert werden."+
" Diese Einwilligung kann ich jederzeit mit Wirkung für die Zukunft"+
" widerrufen, indem ich mich an die Adresse in der"+
" <font color='#0000ff'><u><a href='https://hems.consolinno.de/datenschutz/'>https://hems.consolinno.de/datenschutz/</a></u></font>"+
" wende und um Löschung meines Benutzerkontos bitte. Um diesen Vorgang"+
" zu protokollieren, wird meine IP-Adresse, sowie Datum und Uhrzeit der"+
" Registrierung in einer Datenbank gespeichert und erst wieder"+
" gelöscht, wenn ich die Einwilligung widerrufe, sofern eine"+
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
" unverschlüsselt per Elektronischer Post (Email) an uns senden,"+
" können möglicherweise auf dem Übertragungsweg von Dritten"+
" gelesen werden. Wir können in der Regel auch Ihre Identität nicht"+
" überprüfen und wissen nicht, wer wirklicher Inhaber einer"+
" Emailadresse ist. Eine rechtssichere Kommunikation durch einfache"+
" Email ist daher nicht gewährleistet. Wie viele Anbieter setzen wir"+
" Filter gegen unerwünschte Werbung („SPAM-Filter“) ein, die in"+
" einigen Fällen auch normale Emails fälschlicherweise automatisch"+
" als unerwünschte Werbung einordnen und löschen. Emails, die"+
" schädigende Programme („Viren“) enthalten, werden von uns in"+
" jedem Fall automatisch gelöscht. Wenn Sie schutzwürdige"+
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
" <p style='margin-bottom: 0cm'><b> 7.5 Speicherdauer und Löschung:"+
" </b>Die Daten werden erst dann gelöscht, falls keine vertraglichen"+
" oder gesetzlichen Verpflichtungen einer Löschung entgegenstehen.</p>"+
" <p style='margin-bottom: 0cm'><b> 7.6 Widerspruch oder Widerruf:</b>"+
" Sie können der Kontaktaufnahme per Email jederzeit widersprechen."+
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
" <li><p style='margin-bottom: 0cm'><b>Gültigkeit</b></p>"+
" <p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>Wir"+
" sind stets bemüht, unsere Hard- und Software weiterzuentwickeln und"+
" neue Technologien einzusetzen. Daher kann es notwendig werden, diese"+
" Datenschutzerklärung zu ändern, bzw. anzupassen. Wir behalten uns"+
" daher das Recht vor, diese Erklärung jederzeit mit Wirkung für die"+
" Zukunft zu ändern. Bitte besuchen Sie daher diese Seite regelmäßig"+
" und lesen Sie die jeweils aktuelle Datenschutzerklärung von Zeit zu"+
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
" Aus Gründen der besseren Lesbarkeit wird auf die gleichzeitige"+
" Verwendung der Sprachformen männlich, weiblich und divers (m/w/d)"+
" verzichtet. Sämtliche Personenbezeichnungen gelten gleichermaßen"+
" für alle Geschlechter.</font></p>"+
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
                        text: qsTr("Please connect your Leaflet device (LAN port 1) to your network. Be sure the device running this App (Smartphone, PC) is connected to the same network.")
                    } 
                }

            Image {
                Layout.fillWidth: true
                Layout.preferredHeight: connectionInfoPage.visibleContentHeight - Style.margins * 2
                Layout.margins: Style.margins * 4
                fillMode: Image.PreserveAspectFit
                sourceSize.width: width
                source: "/ui/images/leaflet-ethernet-connect.png"
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
