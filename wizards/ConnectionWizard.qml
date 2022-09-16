import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
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
                onClicked: root.next()
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

    Component {
        id: privacyPolicyComponent
        ConsolinnoWizardPageBase {
            id: privacyPolicyPage

            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(connectionInfo)
            onBack: pageStack.pop()

            background: Item {}
            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
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
" <h3 class='western'><a name='_Ref513466093'></a> 2.1 Bei <u>Vorliegen"+
" der gesetzlichen Voraussetzungen</u> haben Sie - sofern nicht ein"+
" gesetzlicher Ausnahmefall gegeben ist - <font color='#141414'>folgende"+
" Rechte hinsichtlich der Sie betreffenden personenbezogenen Daten:</font></h3>"+
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
" <h3 class='western'> 2.2 Wenn Sie darüber hinaus Auskunft über"+
" Ihre personenbezogenen Daten wünschen oder weitergehende Fragen"+
" über die Verarbeitung Ihrer uns überlassenen personenbezogenen"+
" Daten haben, sowie eine Korrektur oder Löschung Ihrer Daten"+
" veranlassen möchten, so wenden Sie sich bitte an die unter Ziffer"+
" <span style='background: #c0c0c0'>3.</span> <span style='text-decoration: none'>&quot;Ausübung"+
" des </span>Widerspruchs- und Widerrufsrechts<span style='text-decoration: none'>&quot;</span>"+
" angegebene Kontaktadresse.</h3>"+
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
"     <p style='margin-bottom: 0cm'><b> 6. Erteilte Einwilligungen</b><a class='sdfootnoteanc' name='sdfootnote2anc' href='#sdfootnote2sym'><sup>2</sup></a></p>"+
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
" <div id='sdfootnote2'><p class='sdfootnote-western'><a class='sdfootnotesym' name='sdfootnote2sym' href='#sdfootnote2anc'>2</a><font size='1' style='font-size: 8pt'>"+
" Dieser Einwilligungstext muss auch bei der erstmaligen Registrierung"+
" angezeigt und angefragt werden. Das Kästchen zum Setzen des Hakens"+
" darf nicht vorausgefüllt sein. Die Registrierung ist nachhaltig zu"+
" dokumentieren.</font></p>"+
" </div>"+
" <div title='footer'><p align='right' style='margin-top: 0.65cm; margin-bottom: 0cm'>"+
" <font size='1' style='font-size: 8pt'>Seite </font><font size='1' style='font-size: 8pt'><b><span style='background: #c0c0c0'><sdfield type=PAGE subtype=RANDOM format=PAGE>7</sdfield></span></b></font><font size='1' style='font-size: 8pt'> "+
" von </font><font size='1' style='font-size: 8pt'><b><span style='background: #c0c0c0'><sdfield type=DOCSTAT subtype=PAGE format=PAGE>7</sdfield></span></b></font></p>"+
" <p style='margin-bottom: 0cm'><br/>"+
" "+
" </p>"+
" </div>"+
" </body>"+
" </html>"
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
                    }


                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr('I confirm that I have read the the agreement and am accepting it.')
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: policyCheckbox.checked ? qsTr('next') : qsTr('cancel')
                    //color: policyCheckbox.checked ? Style.accentColor : Style.yellow
                    Layout.preferredWidth: 200
                    background: Rectangle{
                        color: policyCheckbox.checked  ? '#87BD26' : 'grey'
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

                Label{
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr( 'In order to connect your device (phone/PC) with the Leaflet you have to be in the same network. \n \n Connect your device with a LAN-cable with the Leaflet (Third ethernet slot). \n\n You can also connect your device to the local Wifi if the Leaflet has a Wifi module.')
                    wrapMode: Text.WordWrap
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

                Label{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    //horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr('You have to authenticate yourself to the Leaflet. For further information look at the manual for commissioning.')

                }


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
