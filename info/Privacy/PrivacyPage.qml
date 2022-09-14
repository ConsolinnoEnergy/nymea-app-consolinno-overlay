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
                           text: "Bavaria ipsum dolor sit amet Biaschlegl Sepp is Gamsbart no gelbe Rüam dringma aweng ja, wo samma denn kimmt. Edlweiss mi da, hog di hi Biawambn hob, sowos gwiss Zwedschgndadschi: Mehra Greichats hod, Maßkruag Schbozal! I sog ja nix, i red ja bloß pfundig so griaß God beinand af Woibbadinga gor Klampfn i i daad abfieseln. Sepp zua Biazelt Maibam, do: Barfuaßat kummd hi helfgod, gor Ledahosn a fescha Bua pfenningguat Blosmusi. Oachkatzlschwoaf soi nomoi noch da Giasinga Heiwog Buam des Gschicht Ledahosn wea nia ausgähd, kummt nia hoam soi, Marterl. Sei Maibam Biakriagal Maßkruag Schneid Goaßmaß und sei hod mechad Goaßmaß! D’ Schmankal Biaschlegl sodala hod, .
   <br><br>
       Mechad woaß da auf’d Schellnsau gar nia need, Freibia. Weißwiaschd Kuaschwanz a Hoiwe trihöleridi dijidiholleri heitzdog no ham, sog i ma kumm geh? Blärrd etza gfreit mi Wiesn am acht’n Tag schuf Gott des Bia, Deandlgwand. I moan scho aa auszutzeln ghupft wia gsprunga i mechad is Zwedschgndadschi Radler Biawambn. Soi Auffisteign back mas, Schdeckalfisch. Woaß pfundig imma, vui huift vui koa weida Fünferl so schee gscheid Servas: Jo mei nimmds Oachkatzlschwoaf is Guglhupf liberalitas Bavariae! Ledahosn Hemad di, is des liab. Ozapfa vo de i sog ja nix, i red ja bloß glei Resi sammawiedaguad, des basd scho Greichats. Resi hawadere midananda des is a gmahde Wiesn nia need schnacksln nix Jodler.
   <br><br>
       Hinter’m Berg san a no Leit Haferl Spuiratz, schüds nei hoam Vergeltsgott Milli! Ebba da, hog di hi Mongdratzal, Bussal a Prosit der Gmiadlichkeit wia da Buachbinda Wanninger Spuiratz Kaiwe a ganze: Helfgod auf’d Schellnsau a liabs Deandl Hetschapfah heid sog i, vui huift vui sowos Gams anbandeln. Bittschön sog i Fünferl, sowos jo mei fias: Fensdaln jedza de Sonn, greaßt eich nachad sei hod vui aasgem Griasnoggalsubbm. Hob wolln noch da Giasinga Heiwog wia da Buachbinda Wanninger des muas ma hoid kenna Sauwedda geh! Zünftig hinter’m Berg san a no Leit Enzian Gschicht boarischer Freibia wia iabaroi des is schee. A Prosit der Gmiadlichkeit i daad hod do! Brodzeid Radler Marterl Ewig und drei Dog, Weißwiaschd oans Heimatland Radler Hemad?
   <br><br>
       Biagadn Buam pfundig von gscheckate, Xaver Sauwedda Heimatland Kirwa ebba. Maibam san i mechad dee Schwoanshaxn hob i an Suri! Gams guad mim des is schee ozapfa oans vasteh Gschicht Sauwedda? Koa g’hupft wia gsprunga spernzaln, do. Hod nia need auffi und glei wirds no fui lustiga des wiad a Mordsgaudi baddscher ned, g’hupft wia gsprunga. Kuaschwanz i mog di fei wolpern, da. Sog i Obazda Haberertanz Engelgwand oans wea nia ausgähd, kummt nia hoam is ma Wuascht, Weibaleid Freibia imma. Auf der Oim, da gibt’s koa Sünd a Hoiwe hob i an Suri sauba jo mei i moan oiwei nix Gwiass woass ma ned Marterl? Und glei wirds no fui lustiga und glei wirds no fui lustiga an Schneid, a ganze Radler Leonhardifahrt i bin a woschechta Bayer Marterl Gschicht oa. Zwoa mogsd a Bussal.
   <br><br>
       Wann griagd ma nacha wos z’dringa Watschnbaam amoi i hab an Radler! Jodler ham muass in da, Schbozal hi Sauakraud umananda glei. Gschicht aasgem wia da Buachbinda Wanninger, allerweil ned Schmankal. Gfreit mi Haferl spernzaln Leonhardifahrt Sauakraud, Brotzeit owe. A ganze Hoiwe i hob di liab imma Heimatland weida i waar soweid koa Fingahaggln sammawiedaguad nia need. Hea nomoi hallelujah sog i, luja Obazda von nimmds eam griasd eich midnand muass, soi! Watschnbaam schoo pfenningguat, hinter’m Berg san a no Leit di i sog ja nix, i red ja bloß Schbozal des is schee. Hallelujah sog i, luja Prosd nimmds jedza Spuiratz i hob di liab Edlweiss Schaung kost nix a so a Schmarn Jodler, vo de. A Hoiwe Mamalad und sei Bladl. ."
                       }
                   }

                   CheckBox {
                       id: policyCheckbox
                       Layout.alignment: Qt.AlignCenter
                   }

                   Label {
                       Layout.fillWidth: true
                       wrapMode: Text.WordWrap
                       horizontalAlignment: Text.AlignHCenter
                       text: qsTr("I confirm that I have read the the agreement and am accepting it.")
                   }
//                   Button {
//                       Layout.alignment: Qt.AlignHCenter
//                       text: policyCheckbox.checked ? qsTr("next") : qsTr("cancel")
//                       //color: policyCheckbox.checked ? Style.accentColor : Style.yellow
//                       Layout.preferredWidth: 200
//                       background: Rectangle{
//                           color: policyCheckbox.checked  ? "#87BD26" : "grey"
//                           radius: 4
//                       }


//                       onClicked: {
//                           if (policyCheckbox.checked) {
//                               pageStack.pop()
//                           } else {
//                               Qt.quit()
//                           }
//                       }
//                   }
               }



}
