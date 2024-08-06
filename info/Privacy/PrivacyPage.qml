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
</div>")+
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
