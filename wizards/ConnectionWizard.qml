import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import 'qrc:/ui/components'
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    headerLabel: qsTr("Terms of Use")
    headerBackButtonVisible: false
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
                    text: qsTr("1. General")
                }

                Text{
                    id: allgemeinText

                    //Layout.fillWidth: true
                    Layout.preferredWidth: app.width - app.margins*2
                    color: Material.foreground
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    //readOnly: true
                    text: qsTr("(1) %1 has developed a software that can be used as an application on Android and IOS systems. The software connects to an energy management system called Leaflet HEMS. This then has the task of maximizing the self-consumption of PV energy in conjunction with a photovoltaic system. The black-out protection function is also integrated. This dynamically limits the charging current of a charging device. The fuse does not trip.").arg(Configuration.companyName)
                }

                Text{
                    id: allgemeinText2

                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("The software makes it possible to significantly increase the self-consumption of the generated PV energy by controlling an e-charging device, a heat pump, household appliances (washing machine, dryer, dishwasher) and by integrating a battery.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("This saves CO2 and costs.")
                }

                Text{
                    id: allgemeinText4

                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("These general license terms apply to all license agreements with the customer regarding the software modules and the HEMS product.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) The software is offered by %1 free of charge to HEMS customers via app stores.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Customers are responsible for the proper installation of hardware and software.")
                }


                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("2. License object")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) %1 grants the customer the exclusive right to use the software described in more detail in the agreement within Germany. A non-exclusive and non-transferable right to use the software is granted.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) The software may be reproduced to the extent necessary for the contractual use.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("The customer can download and install the program using the respective operating system via the app stores.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Furthermore, the customer is not entitled to copy or transfer the software to third parties, unless otherwise provided by law.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) The customer is not entitled to change or edit the software unless the change or editing is necessary to eliminate a defect that is necessary for the contractual use of the software and with which %1 is in default.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("3.License fee")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) By purchasing the HEMS device, the customer has downloaded the software free of charge from the APP Stores and can use it.")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) As part of further development, software modules can also be purchased for an unlimited period of use.")
                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.bold: true
                    font.pixelSize: 15
                    text: qsTr("4.Software delivery and installation")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) %1 delivers the software to the customer via the Apple or Google app store.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) In addition to the software, %1 will offer the customer installation instructions for the HEMS device as well as documentation for download.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) %1 is not responsible for installing the software on the customer's systems; the customer is solely responsible for this.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("5. Maintenance")
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) %1 is obliged to maintain the contractually agreed quality of the software during the term of the contract ('maintenance'). The contractually agreed quality of the software is determined by the promised function of the HEMS product. Updates are carried out via an Internet connection.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) %1 is only obliged to change, adapt or further develop the software if this has been separately agreed with the customer. Without such a separate agreement, %1 is not obliged to further develop the software.").arg(Configuration.companyName)
                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("6.Warranty")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) If the customer discovers defects in the software, the device or the documentation, the customer must inform %1. This can be done, for example, by email.").arg(Configuration.companyName)

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) A defect does not exist if the hardware and/or software used by the customer does not meet the specified requirements.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) %1 will remedy the reported defects in the software and documentation within a reasonable period of time. When remedying the defect, %1 has the right to choose between repair and replacement delivery. %1 will bear the costs of remedying the defect. Costs for downtime, lost profits, installation and removal costs or similar will not be reimbursed.").arg(Configuration.companyName)

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) If the remedy of defects owed here fails, the customer is entitled to extraordinary termination of the contract in question in accordance with Section 543 Paragraph 2 Sentence 1 No. 1 of the German Civil Code (BGB).")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("8. Liability")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) The licensor is liable without limitation:

· in the event of malice, intent or gross negligence;

· within the scope of a guarantee expressly given by him;

· for damages resulting from injury to life, body or health;

· in accordance with the provisions of the Product Liability Act")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Furthermore, %1’s liability for direct and indirect damages is excluded.").arg(Configuration.companyName)

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Open Source

Open source modules are included in the APP and in the device software. The corresponding guarantee and liability conditions apply to these modules. If this is not possible, the regulations in the respective user country apply.")

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("9. Contract duration and termination")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) The license agreement comes into force upon acceptance of the license terms prior to installation and is valid for an indefinite period.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) The right of both parties to terminate the contract at any time for good cause and without notice remains unaffected. Good cause exists in particular if the licensor or licensee intentionally or negligently violates a material obligation under these license terms and conditions and the terminating party can therefore no longer reasonably be expected to adhere to the license agreement. The licensor is therefore entitled to terminate the license agreement for good cause and without notice if the licensee exceeds the rights of use granted to it and does not stop its infringements within a reasonable period of time, if the licensor has previously warned the licensee to refrain from these infringements.")

                }


                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) Termination of the License Agreement must be in writing.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) %1 may stop maintaining the program without giving reasons").arg(Configuration.companyName)

                }

                Text{
                    Layout.topMargin: 30
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    font.bold: true
                    text: qsTr("11. Final provisions")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(1) Should one of these license terms or a provision later included in this license agreement be or become invalid or unenforceable in whole or in part, or should a gap in these license terms emerge, the validity of the remaining provisions shall not be affected thereby (preservation). It is the express intention of the parties to maintain the validity of the remaining provisions under all circumstances and thus to waive Section 139 of the German Civil Code (BGB) in its entirety. Instead of the invalid or unenforceable provision or to fill the gap, the effective and enforceable provision shall be deemed to have been determined with retroactive effect, which legally and economically comes closest to what the parties wanted or would have wanted according to the spirit and purpose of the license agreement if they had considered this point when concluding this agreement or when including the provision; if the invalidity of a provision is based on a level of performance or time (deadline or date) specified therein, the provision shall be deemed to have been agreed with a legally permissible level that comes closest to the original level (fiction of replacement). If the fiction of replacement is not possible, a provision or regulation must be made in place of the invalid or unenforceable provision or to close the gap in accordance with the content of the previous sentence (obligation to replace). If the invalidity or gap concerns a provision that requires notarization, the regulation or provision must be agreed in notarized form.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(2) Any amendments or additions to the relevant licence agreement, including this clause, must be made in writing unless otherwise specified.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(3) The parties may only transfer the License Agreement and any rights and obligations arising from the License Agreement to a third party with the prior written consent of the other party.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(4) The validity of the licensee’s general terms and conditions is expressly excluded.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("(5) The exclusive place of jurisdiction for all disputes arising from or in connection with the license agreement is the registered office of the licensor, Regensburg. The licensor remains entitled to bring an action at the general place of jurisdiction of the licensee.")

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Licensor address
%1, %2").arg(Configuration.companyName).arg(Configuration.companyAddress)

                }

                Text{
                    Layout.topMargin: 15
                    color: Material.foreground
                    Layout.preferredWidth: app.width - app.margins*2
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    text: qsTr("Tel %1
Mail %2").arg(Configuration.companyTel).arg(Configuration.serviceEmail)

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
            enabled: readCheckbox.checked


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

            headerVisible: false
            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(connectionInfo)
            onBack: pageStack.pop()

            background: Item {}
            content: Item {
                anchors.fill: parent

                ColumnLayout {
                    id: contentColumn

                    //                anchors.fill: parent
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: Style.margins
                        bottomMargin: Style.margins
                        leftMargin: Style.margins
                        rightMargin: Style.margins
                    }
                    spacing: Style.hugeMargins

                    Image {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 4
                        source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
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
                            text: qsTr('Welcome to %1!').arg(Configuration.branding)
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

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            text: qsTr('Back')
                            background: Rectangle{
                                color: 'grey'
                                radius: 4
                            }
                            onClicked: pageStack.pop()
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

            headerLabel: qsTr("Privacy Policy and License Agreement\n(09/2022)")
            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(demoModeComponent)
            onBack: pageStack.pop()

            background: Item {}
            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; right: parent.right; left: parent.left }
                width: Math.min(parent.width, 450)

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
                        text: "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0 Transitional//EN'>" +
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
                              " <body lang='de-DE' link='#0000ff' vlink='#800080' dir='ltr'><p class='western' align='center' style='margin-left: 0.64cm; margin-bottom: 0cm'></p>"+
                              qsTr("<p class='western' style='margin-bottom: 0cm'>We process your personal data according to the current regulations of the Federal Republic of Germany and the European Union (EU). The protection of your personal information is our highest priority. Below you will find information about which data we process, in what form, on what legal basis, for what purpose, and for how long, to what extent you have the right to object, and how you can exercise this right. If your consent is required, it will be indicated at the relevant point, and you will have the option to grant or withhold it. Of course, even after granting your consent, you have the right to withdraw it at any time.<font color='#333333'>&nbsp;</font></p>
<p class='western' style='margin-bottom: 0cm'><br/></p>
<ol>
  <h3 class='western'>1. Responsible Party<span style='font-weight: normal'><a class='sdfootnoteanc' name='sdfootnote1anc' href='#sdfootnote1sym'><sup>1</sup></a></span><br/>
  Responsible according to data protection regulations is:</h3>
</ol>
<p class='western' style='margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><b>%2</b></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>represented by the managing director</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>%3</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>%1 %4</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>The responsible company data protection officer (bDSB) is:</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Niklas Hanitsch</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Datenschutz hoch 4 GmbH</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>%3</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>%1 %4</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><a name='_Hlk514794356'></a>We would like to point out your <u>right to lodge a complaint with the supervisory authority</u> according to Art. 77 GDPR. Every data subject has the right to lodge a complaint with the supervisory authority, regardless of other legal remedies, if they believe that the processing of their personal data violates the General Data Protection Regulation.</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>The contact details of the supervisory authority responsible for the controller are:</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><font color='#000000'><span style='background: #ffffff'>Bavarian State Office for Data Protection Supervision</span></font></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>Promenade 18</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'>91522 Ansbach</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>
<ol start='2'>
  <h3 class='western'>2. Information about Your Rights as a Data Subject</h3>
  <ol>
    <h3 class='western'><a name='_Ref513466093'></a>2.1</h3> If <u>legal requirements are met</u>, you have - unless there is a legal exception - <font color='#141414'>the following rights regarding your personal data:</font>
  </ol>
</ol>
<p style='margin-left: 1.33cm; margin-bottom: 0cm'><br/></p>
<ul>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>information</b></u> (Art. 15 GDPR): You have the right to request information from the controller about whether personal data concerning you is being processed. If so, you have the right to obtain information about this personal data and related additional information.</p></li>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>rectification</b></u> (Art. 16 GDPR): You have the right to request the immediate correction of inaccurate personal data concerning you. Taking into account the purposes of the processing, you have the right to request the completion of incomplete personal data – including by providing a supplementary statement.</p></li>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>erasure</b></u> (Art. 17 GDPR): You have the right to request the immediate deletion of personal data concerning you from the controller, and the controller is obliged to delete personal data immediately if one of the reasons under Art. 17(1) GDPR applies and no exception applies.</p></li>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>restriction of processing</b></u> (Art. 18 GDPR): You have the right to request the restriction (formerly: blocking) of the processing of your personal data from the controller if one of the conditions under Art. 18(1) GDPR applies and no exception applies.</p></li>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>data portability</b></u> (Art. 20 GDPR): You have the right to receive the personal data concerning you, which you have provided to a controller, in a structured, commonly used, and machine-readable format, and you have the right to transmit this data to another controller without hindrance from the controller to whom the personal data was provided, provided the further conditions of Art. 20(1) GDPR are met and no exception applies.</p></li>
  <li><p style='margin-bottom: 0cm'>Right to <u><b>object to processing</b></u> (Art. 21 GDPR): You have the right to object at any time, on grounds relating to your particular situation, to the processing of personal data concerning you which is based on Art. 6(1) sentence 1 lit. e) (public interest or exercise of official authority) or f) (protection of legitimate interests) GDPR.</p></li>
</ul>
<p style='margin-left: 2.6cm; margin-bottom: 0cm'><br/></p>
<ol>
  <ol start='2'>

<p class='western'>2.2 If you wish to obtain further information about your personal data or have additional questions regarding the processing of the personal data you have provided to us, or if you want to request correction or deletion of your data, please contact the address provided in Section <span style='background: #c0c0c0'>3.</span> <span style='text-decoration: none'>“Exercise of the</span> Right of Objection and Withdrawal<span style='text-decoration: none'>”</span>.</p>

<p class='western' style='margin-bottom: 0cm'><br/></p>

<ol start='3'>
  <h3 class='western'><a name='_Ref514808556'></a><a name='_Ref493089160'></a>3. Exercise of the Right of Objection and Withdrawal</h3>
</ol>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span style='font-weight: normal'>You may have the right to object to the processing of your data (see Section <span style='background: #c0c0c0'>2.1</span> last bullet point). Additionally, you have the right to withdraw any consent you have given us with future effect. In this case, we will immediately cease processing your data for that purpose. You can submit an objection or withdrawal at any time informally by mail, fax, or email.</span></p>

<p class='western' style='margin-left: 0.61cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span lang='en-US'>By Mail:</span></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'> %2</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'> %3</p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'> %1 %4</p>

<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><span lang='en-US'>By Email:</span></p>
<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'> %5</p>

<p class='western' style='margin-bottom: 0cm'><br/></p>

<ol start='4'>
  <h3 class='western'>4. Use of Hardware and Mobile Application (App)</h3>
  <ol>
    <h3 class='western'><b>4.1 Type and Scope of Data Processing:</b></h3>
    <p>When using our hardware and accessing our app, it is technically necessary to process various data, particularly to enable use and ensure error-free communication between your device and our cloud. Automated data collected and logged in a so-called log file include:</p>
    <ul>
      <li>Date and time of access</li>
      <li>Hardware type and version (including serial number)</li>
      <li>Operating system type and version</li>
      <li>IP addresses of devices</li>
      <li>The IP address of your connection</li>
      <li>Access provider</li>
      <li>Data of connected mobile devices (manufacturer, type), stored exclusively on the hardware</li>
      <li>Data of devices integrated into the smart home system (operating statuses, operating hours, energy consumption, system status, system settings, installation location, error codes, measurements such as temperatures), stored exclusively on the hardware</li>
    </ul>
    <p>We generally collect this data in a non-personalized form. In exceptional cases, the identification with a natural person cannot be avoided. For additional data processing within the scope of the beta test, please refer to Section 6 below.</p>
  </ol>
</ol>

<p class='western' style='margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 1.25cm; margin-bottom: 0cm'><b>4.2 Purpose:</b></p>
<p>This is done to enable the use of hardware and software, particularly for internal technical processing (connection establishment), system security, technical administration of the system and network infrastructure, and optimization of our offering and product. We reserve the right to review the log file afterwards if there is a specific indication of a legitimate suspicion of illegal or abusive use.</p>

<p class='western' style='margin-bottom: 0cm'><b>4.3 Legal Basis:</b></p>
<p>The temporary processing of the data and the log file occurs on the basis of legitimate interest for the above-mentioned purpose according to Art. 6(1) sentence 1 lit. f) GDPR and for the fulfillment of the contract with you according to Art. 6(1) sentence 1 lit. b) GDPR.</p>

<p class='western' style='margin-bottom: 0cm'><b>4.4 Recipients of the Data:</b></p>
<p>The anonymized data is necessarily forwarded to our hosting provider, who physically and technically manages our web server:
**Hosting Provider:** Hetzner Online GmbH, Industriestr. 25, 91710 Gunzenhausen</p>

<p class='western' style='margin-bottom: 0cm'><b>4.5 Storage Duration and Deletion:</b></p>
<p>The IP address is only stored with remote access. Data storage is based on legal regulations.</p>

<p class='western' style='margin-bottom: 0cm'><b>4.6 Objection or Withdrawal:</b></p>
<p>This data processing is necessary for the operation of our hardware and software. Therefore, any objection is subject to an appropriate balancing of interests.</p>

<p class='western' style='margin-bottom: 0cm'><br/></p>

<h3 class='western'><a name='_Ref493089341'></a>5. Registration</h3>
<h3 class='western'><b>5.1 Type and Scope of Data Processing:</b></h3>
<p>You have the option to register in our app. Your consent is required for this. To successfully complete the registration process, we need the following data from you:</p>
<ul>
  <li>Email address</li>
  <li>Password</li>
</ul>

<p>During registration, your IP address along with the date and time is also stored. A personal evaluation generally does not take place, subject to participation in the beta test (see Section 6). However, we reserve the right to review the stored data afterwards if there is a specific indication of a legitimate suspicion of abusive registration.</p>

<h3 class='western'><b>5.2 Purpose:</b></h3>
<p>Registration provides you with the ability to use certain services or perform actions that are not possible without registration. This is done for the following purposes:</p>
<ul>
  <li>Operation of hardware and software</li>
  <li>Use of the app</li>
  <li>Use of the cloud</li>
</ul>
<p>Your data is stored in our system to allow you to use our services without having to re-enter your data every time. Your email address will be used by us to send you confirmation emails for changes you have made to your profile data or for password recovery, as well as to inform you about necessary software updates. We will only send you other emails if you wish and have given us your consent for this purpose. The storage of your IP address along with the date and time is done for abuse prevention.</p>

<h3 class='western'><b>5.3 Legal Basis:</b></h3>
<p>The processing of the data is based on your consent according to Art. 6(1) sentence 1 lit. a) GDPR.</p>

<h3 class='western'><b>5.4 Storage Duration and Deletion:</b></h3>
<p>The data is generally stored as long as you do not cancel your registration and no legal retention periods are in place.</p>

<h3 class='western'><b>5.5 Objection or Withdrawal:</b></h3>
<p>You have the right to cancel your registration at any time and to change your stored data as well as to withdraw your given consent with future effect. You can change your password at any time yourself. In case of cancellation and/or withdrawal, access to the hardware and software will no longer be possible.</p>

<p class='western' align='left' style='margin-bottom: 0cm; line-height: 100%'><br/></p>

<p class='western' style='margin-bottom: 0cm; page-break-before: always'><br/></p>

<p style='margin-left: 1.27cm; margin-bottom: 0cm'><br/></p>

<p style='margin-bottom: 0cm'><b>6. Given Consents</b></p>
<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>Where necessary, you may have given us consents for the processing of your personal data. In this case, we have documented your consent. We are legally obligated to keep the text of each consent available to you at any time. You can of course withdraw any given consents with future effect at any time. You can find out how to exercise your right of withdrawal under Section <span style='background: #c0c0c0'>3.</span> <span style='text-decoration: none'>“Exercise of the</span> Right of Objection and Withdrawal<span style='text-decoration: none'>”</span>.</p>
<p class='western' style='margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><b>Consent for Registration of a User Account:</b></p>
<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>I would like to open a user account to be able to log into the app. For this purpose, I consent to my data (email address and password) being stored in the database. I can withdraw this consent at any time with future effect by contacting the address in the <font color='#0000ff'><u><a href='%6'>%6</a></u></font> and requesting deletion of my user account. To document this process, my IP address, as well as the date and time of registration, will be stored in a database and will only be deleted when I withdraw my consent, unless further storage is legally required. The terms and conditions at <font color='#0000ff'><u><a href='%7'>%7</a>/</u></font> have been read and understood.</p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<h3 class='western'><br/></h3>

<p style='margin-bottom: 0cm'><b>7. Electronic Mail (Email) / Contact</b></p>
<p style='margin-bottom: 0cm'><b>7.1 Information sent unencrypted via Electronic Mail (Email) may potentially be read by third parties during transmission. We usually cannot verify your identity and do not know who the actual owner of an email address is. Secure communication via simple email is therefore not guaranteed. Like many providers, we use filters against unwanted advertising (“SPAM filters”), which in some cases may automatically classify and delete normal emails as unwanted advertising. Emails containing harmful programs (“viruses”) will be automatically deleted. If you want to send us sensitive messages, we recommend sending them by conventional mail.</b></p>

<p style='margin-bottom: 0cm'><b>7.2 Type and Scope of Data Processing:</b> If you contact us, your data, your IP address, as well as the date and time will be stored.</p>
<p style='margin-bottom: 0cm'><b>7.3 Purpose:</b> This is done particularly for communication purposes and to protect our systems against abuse.</p>
<p style='margin-bottom: 0cm'><b>7.4 Legal Basis:</b> The processing of the data is carried out on the basis of legitimate interest for the above-mentioned purpose according to Art. 6(1) sentence 1 lit. f) GDPR.</p>
<p style='margin-bottom: 0cm'><b>7.5 Storage Duration and Deletion:</b> The data will only be deleted if no contractual or legal obligations to retain them exist.</p>
<p style='margin-bottom: 0cm'><b>7.6 Objection or Withdrawal:</b> You may object to contact via email at any time. In this case, no further correspondence via email can take place.</p>

<p class='western' style='margin-bottom: 0cm'><br/></p>

<h3 class='western'><b>8. Validity</b></h3>
<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'>We are continually working to develop our hardware and software and to use new technologies. Therefore, it may be necessary to change or adapt this privacy policy. We reserve the right to modify this statement at any time with future effect. Please visit this page regularly and review the current privacy policy from time to time.</p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<p class='western' style='margin-left: 0.64cm; margin-bottom: 0cm'><br/></p>

<div id='sdfootnote1'>
  <p class='sdfootnote-western'>
    <a class='sdfootnotesym' name='sdfootnote1sym' href='#sdfootnote1anc'>1</a>
    <font size='1' style='font-size: 8pt'>For better readability, the simultaneous use of male, female, and diverse language forms (m/f/d) is omitted. All personal designations apply equally to all genders.</font>
  </p>
</div>
                              ").arg(Configuration.companyZip).arg(Configuration.companyName).arg(Configuration.companyAddress).arg(Configuration.companyLocation).arg(Configuration.serviceEmail).arg(Configuration.privacyPolicyUrl).arg(Configuration.termsOfConditionsUrl)+
                              "</body>"+
                              "</html>"
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
                    enabled: policyCheckbox.checked && accountCheckbox.checked


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

            headerLabel: qsTr("Internet Connection")
            showNextButton: false
            showBackButton: false
            background: Item {}
            onNext: pageStack.push(findLeafletComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
                width: Math.min(parent.width, 450)

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
                    Layout.margins: Style.margins * 3
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: width
                    source: "/ui/images/leaflet-ethernet-connect.png"
                }


                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('next')
                    //color: Style.accentColor
                    Layout.preferredWidth: 200

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

            headerLabel: qsTr("Discovered Devices")
            showBackButton: false
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
            }
        }
    }

    Component {
        id: manualConnectionComponent

        ConsolinnoWizardPageBase {
            //            title: qsTr('Manual connection')
            //            text: qsTr('Please enter the connection information for your nymea system')
            headerLabel: qsTr("Manual Connection")
            showBackButton: false
            showNextButton: false
            background: Item {}

            content: Item {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Style.margins
                    bottomMargin: Style.margins
                    leftMargin: Style.margins
                    rightMargin: Style.margins
                }

                GridLayout {
                    id: manualConnectionDetailsGridLayout

                    width: parent.width
                    height: parent.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    columns: 2

                    Label {
                        text: qsTr('Protocol')
                    }

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr("TCP"), qsTr("Websocket"), qsTr("Remote proxy") ]
                    }

                    Label {
                        text: connectionTypeComboBox.currentIndex < 2 ? qsTr("Address:") : qsTr("Proxy address:")
                    }
                    TextField {
                        id: addressTextInput
                        objectName: "addressTextInput"
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex < 2 ? "127.0.0.1" : "hems-remoteproxy.services.consolinno.de"
                    }

                    Label {
                        text: qsTr("%1 UUID:").arg(Configuration.systemName)
                        visible: connectionTypeComboBox.currentIndex == 2
                    }
                    TextField {
                        id: serverUuidTextInput
                        Layout.fillWidth: true
                        visible: connectionTypeComboBox.currentIndex == 2
                    }
                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0
                                         ? "2222"
                                         : connectionTypeComboBox.currentIndex == 1
                                           ? "4444"
                                           : "2213"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("SSL:")
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }

                Button {
                    width: 200
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: manualConnectionDetailsGridLayout.bottom
                    anchors.topMargin: Style.margins
                    text: qsTr('Next')
                    onClicked: {
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
                        } else if (connectionTypeComboBox.currentIndex == 2) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "tunnels://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
                            } else {
                                rpcUrl = "tunnel://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
                            }
                        }

                        print('Try to connect ', rpcUrl)
                        var host = nymeaDiscovery.nymeaHosts.createWanHost('Manual connection', rpcUrl);
                        engine.jsonRpcClient.connectToHost(host)
                    }
                }
            }
        }
    }
}
