import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

StackView {
    id: root

    property string startView

    initialItem: startView === "taxesAndFeesSetUp" ? taxesAndFeesSetUp : setUpComponent


    property HemsManager hemsManager
    property string name
    property bool newTariff: false
    property Thing dynElectricThing : thing.get(0)
    property int directionID: 0
    property var busyOverlay
    signal done(bool skip, bool abort, bool back);

    QtObject {
        id: d
        property int pendingCallId: -1
        property var pairingTransactionId: null
        property var params: []
        property Thing thingToRemove
    }

    ThingsProxy {
        id: thing
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    ThingClassesProxy {
        id: thingClassesProxy
        engine: _engine
        includeProvidedInterfaces: true
        groupByInterface: true
        filterInterface: "dynamicelectricitypricing"
    }

    Connections {
        id: connection
        target: engine.thingManager

        onPairThingReply: {
            if (thingError !== Thing.ThingErrorNoError) {
                busyOverlay.shown = false;
                pageStack.push(dynamicSetUpFeedBack, {thingError: thingError, message: displayMessage});
                return;
            }

            d.pairingTransactionId = pairingTransactionId;

            switch (setupMethod) {
            case "SetupMethodPushButton":
            case "SetupMethodDisplayPin":
            case "SetupMethodEnterPin":
            case "SetupMethodUserAndPassword":
                pageStack.push(pairingPageComponent, {text: displayMessage, setupMethod: setupMethod})
                break;
            case "SetupMethodOAuth":
                pageStack.push(oAuthPageComponent, {oAuthUrl: oAuthUrl})
                break;
            default:
                print("Setup method reply not handled:", setupMethod);
            }
        }

        onConfirmPairingReply: {
            pageStack.push(dynamicSetUpFeedBack, {comboBoxCurrentText: thing.get(0).name, thingPair: true})
        }

        onAddThingReply: {
            busyOverlay.shown = false;
            pageStack.push(dynamicSetUpFeedBack, {comboBoxCurrentText: thing.name})
        }

    }

    Component {
        id: setUpComponent
        Page {

            header: NymeaHeader {
                text: qsTr("Dynamic electricity tariff")
                backButtonVisible: true
                onBackPressed: {
                    if(directionID == 0) {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;}
                spacing: 0

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Submitted Rate")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: app.margins
                        horizontalAlignment: Text.AlignRight
                    }
                }

                VerticalDivider
                {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }

                Flickable {
                    id: flickableContainer
                    clip: true


                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        id: column
                        Layout.topMargin: 0
                        width: parent.width
                        //Layout.minimumHeight: 230
                        spacing: 0

                        Repeater {
                            id: dynamicRateRepeater
                            model: ThingsProxy {
                                id: erProxy
                                engine: _engine
                                shownInterfaces: ["dynamicelectricitypricing"]
                            }
                            delegate: ConsolinnoThingDelegate {
                                implicitHeight: 50
                                Layout.fillWidth: true
                                iconName: Configuration.energyIcon !== "" ? "/ui/images/"+Configuration.energyIcon : "../images/energy.svg"
                                text: model.name
                                progressive: true
                                canDelete: true
                                onClicked: {
                                    if(erProxy.get(0).thingClass.setupMethod !== 4){
                                        pageStack.push(taxesAndFeesSetUp, {thingClass : dynElectricThing.thingClass, reconfiguration: true})
                                    }
                                }
                                onDeleteClicked: {
                                    engine.thingManager.removeThing(model.id)
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    Layout.preferredHeight: parent.height / 3
                    Layout.fillWidth: true
                    visible: erProxy.count === 0
                    color: Material.background
                    Text {
                        text: qsTr("There is no rate set up yet")
                        color: Material.foreground
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignHCenter
                    }
                }

                VerticalDivider
                {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                    visible: thing.count >= 1 ? false : true
                }

                ColumnLayout {
                    Layout.topMargin: Style.margins
                    visible: (root.newTariff && thing.count === 0 )
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        text: qsTr("Add Rate: ")
                        wrapMode: Text.WordWrap
                    }

                    ConsolinnoDropdown {
                        id: energyRateComboBox
                        Layout.leftMargin: Style.margins
                        Layout.fillWidth: true
                        textRole: "displayName"
                        valueRole: "id"
                        model: ThingClassesProxy {
                            id: currentThing
                            engine: _engine
                            filterInterface: "dynamicelectricitypricing"
                            includeProvidedInterfaces: true
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    visible: thing.count >= 1 ? false : true

                    Button {
                        id: addButton
                        text: qsTr("Add Rate")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        property ThingClass thingClass: thingClassesProxy.get(energyRateComboBox.currentIndex)
                        onClicked: {
                            if(!root.newTariff) {
                              root.newTariff = true;
                              addButton.text = qsTr("Next");
                              return;
                            }

                            if(thingClass.setupMethod !== 4){
                                pageStack.push(taxesAndFeesSetUp, {comboBoxValue: energyRateComboBox.currentValue, comboBoxCurrentText: energyRateComboBox.currentText, comboBoxCurrentIndex: energyRateComboBox.currentIndex, thingClass: thingClass} );
                            }else{
                                pageStack.push(oAuthPageComponent, {comboBoxValue: energyRateComboBox.currentValue, comboBoxCurrentText: energyRateComboBox.currentText, comboBoxCurrentIndex: energyRateComboBox.currentIndex} );
                                engine.thingManager.pairThing(energyRateComboBox.currentValue, {} ,energyRateComboBox.currentText)
                            }
                        }
                    }

                    ConsolinnoSetUpButton {
                        text: qsTr("Cancel")
                        backgroundColor: "transparent"
                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: taxesAndFeesSetUp

        Page {

            property var comboBoxValue
            property string comboBoxCurrentText: ""
            property int comboBoxCurrentIndex: 0
            property bool reconfiguration: false
            property bool btnDelete: false
            property bool backToView: dynElectricThing.paramByName("addedGridFee").value === 0 ? true : false
            property var thingClass

            Component.onCompleted: {
               thingClass = dynElectricThing.thingClass
            }

            header: ConsolinnoHeader {
                text: qsTr("Dynamic electricity tariff")
                backButtonVisible: true
                onMenuOptionsPressed: menu.open()
                onBackPressed: {
                    if(directionID >= 0) {
                        pageStack.pop()
                    }
                }
            }

            Connections {
                target: engine.thingManager
                onThingRemoved: {
                    if(btnDelete === true){
                        busyOverlay.shown === false
                        pageStack.pop()
                    }
                }
            }

            function addParamValues(){
                var params = []
                for (var i = 0; i < thingClass.paramTypes.count; i++) {
                    var param = {}
                    var paramId = thingClass.paramTypes.get(i).id
                    var paramName = thingClass.paramTypes.get(i).name
                    if(paramName === "marketArea"){
                        param.paramTypeId = paramId
                        param.value = countryCode.currentText
                    }else if(paramName === "addedGridFee"){
                        param.paramTypeId = paramId
                        param.value = parseFloat(addedGridFee.text.replace(",","."))
                    }else if(paramName === "addedLevies"){
                        param.paramTypeId = paramId
                        param.value = parseFloat(addedLevies.text.replace(",","."))
                    }else if(paramName === "addedVAT"){
                        param.paramTypeId = paramId
                        param.value = parseFloat(vat.text)
                    }
                    params.push(param)
                    d.params = params
                }
            }

            ColumnLayout {
                anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;}
                Layout.fillWidth: true
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            Layout.rightMargin: 20
                            rightPadding: 16
                            text: qsTr("Location")
                        }

                        ConsolinnoDropdown {
                            property var paramsValueArray: isNaN(dynElectricThing) ? dynElectricThing.thingClass.paramTypes.get(2).allowedValues : 0
                            model: thingClass ? thingClass.paramTypes.get(2).allowedValues : dynElectricThing.thingClass.paramTypes.get(2).allowedValues
                            id: countryCode
                            Layout.fillWidth: true
                            currentIndex: isNaN(dynElectricThing) ? paramsValueArray.indexOf(dynElectricThing.paramByName("marketArea").value) : 0
                        }
                    }

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            rightPadding: 16
                            text: qsTr("Network charges")
                        }

                        TextField {
                            id: addedGridFee
                            Layout.rightMargin: 12
                            validator: RegExpValidator { regExp: /^[0-9.,]*$/ }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: isNaN(dynElectricThing) ? (dynElectricThing.paramByName("addedGridFee").value).toLocaleString() : ""
                        }

                        Label {
                            text: "ct/kWh"
                        }
                    }

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            rightPadding: 16
                            Layout.fillWidth: true
                            text: qsTr("Taxes & fees")
                        }

                        TextField {
                            id: addedLevies
                            Layout.rightMargin: 12
                            validator: RegExpValidator { regExp: /^[0-9.,]*$/ }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: isNaN(dynElectricThing) ? (dynElectricThing.paramByName("addedLevies").value).toLocaleString() : ""
                        }

                        Label {
                            text: "ct/kWh"
                        }
                    }

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            rightPadding: 16
                            Layout.fillWidth: true
                            text: qsTr("VAT")
                        }

                        TextField {
                            id: vat
                            Layout.rightMargin: 12
                            validator: RegExpValidator { regExp: /^[0-9]*$/ }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            text: isNaN(dynElectricThing) ? (dynElectricThing.paramByName("addedVAT").value).toLocaleString() : ""
                        }

                        Label {
                            Layout.rightMargin: 39
                            text: "%"
                        }
                    }


                    Label {
                        id: footer
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        color: Style.dangerAccent
                        wrapMode: Text.WordWrap
                        font.pixelSize: app.smallFont
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignHCenter

                        Button {
                            id: saveButton
                            text: qsTr("Save")
                            Layout.fillWidth: true
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: {
                                if(parseFloat(addedGridFee.text) > 0 && parseFloat(addedLevies.text) > 0){
                                    addParamValues();
                                    if(reconfiguration === false && !isNaN(dynElectricThing)){
                                        pageStack.push(dynamicSetUpFeedBack,{comboBoxCurrentText});
                                        engine.thingManager.addThing(comboBoxValue, comboBoxCurrentText, d.params);

                                    }else{
                                        engine.thingManager.removeThing(dynElectricThing.id)
                                        engine.thingManager.addThing(dynElectricThing.thingClass.id, dynElectricThing.name, d.params);
                                        pageStack.push(dynamicSetUpFeedBack,{comboBoxCurrentText: dynElectricThing.name, reconfiguration: true, historyView: backToView});
                                    }
                                }else {
                                    footer.text = qsTr("Please enter taxes and duties. The value cannot be empty or 0.")
                                }
                            }
                        }

                        ConsolinnoSetUpButton {
                            text: qsTr("Cancel")
                            backgroundColor: "transparent"
                            onClicked: {
                                if(directionID === 0){
                                    pageStack.pop()
                                    pageStack.pop()
                                }else{
                                    pageStack.pop()
                                }
                                dynElectricThing = null
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Component {
        id: oAuthPageComponent
        Page {
            id: oAuthPage
            property string oAuthUrl

            header: NymeaHeader {
                text: qsTr("Zewotherm setup")
                onBackPressed: {
                    pageStack.pop()
                    pageStack.pop()
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins * 2

                Label {
                    Layout.fillWidth: true
                    text: qsTr("OAuth is not supported on this platform. Please use this app on a different device to set up this thing.")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("In order to use OAuth on this platform, make sure qml-module-qtwebview is installed.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Item {
                id: webViewContainer
                anchors.fill: parent

                Component.onCompleted: {
                    // This might fail if qml-module-qtwebview isn't around
                    var webView = Qt.createQmlObject(webViewString, webViewContainer);
                    print("created webView", webView)
                }

                property string webViewString:
                    '
                    import QtQuick 2.8;
                    import QtWebView 1.1;
                    import QtQuick.Controls 2.2
                    import Nymea 1.0;

                    Rectangle {
                        anchors.fill: parent
                        color: Style.backgroundColor

                        BusyIndicator {
                            id: busyIndicator
                            anchors.centerIn: parent
                            running: oAuthWebView.loading
                        }

                        WebView {
                            id: oAuthWebView
                            anchors.fill: parent
                            url: oAuthPage.oAuthUrl

                            onUrlChanged: {
                                print("OAUTH URL changed", url)
                                if (url.toString().indexOf("https://127.0.0.1") == 0) {
                                    print("Redirect URL detected!");
                                    engine.thingManager.confirmPairing(d.pairingTransactionId, url)
                                    busyIndicator.running = true
                                    oAuthWebView.visible = false
                                }
                            }
                        }
                    }
                    '
            }
        }
    }

    Component {
        id: dynamicSetUpFeedBack

        Page {
            id: dynamicSetUpFeedBackPage

            property string comboBoxCurrentText: ""
            property bool reconfiguration: false
            property bool thingPair: false
            property bool historyView: false

            Connections {
                target: engine.thingManager

                onAddThingReply: {
                    if(!thingError)
                    {
                        busyOverlay.shown = false;
                        dynElectricThing = engine.thingManager.things.getThing(thingId);
                    }else{
                        let props = qsTr("Failed to add thing: ThingErrorHardwareFailure");
                        var comp = Qt.createComponent("../components/ErrorDialog.qml")
                        var popup = comp.createObject(app, {props} )
                        popup.open();
                    }
                }
            }

            Component.onCompleted: {
                if(thingPair === true){
                    busyOverlay.shown = false;
                }else{
                    busyOverlay.shown = true;
                }
            }

            header: ConsolinnoHeader {
                text: qsTr("Dynamic electricity tariff")
                Layout.fillWidth: true
                backButtonVisible: true
                onBackPressed: {
                    if(directionID == 0) {
                        dynElectricThing = null
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; }
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: Material.foreground
                        text: qsTr("The following tariff is submitted:")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.Center
                    }

                    Text {
                        id: electricityRate
                        Layout.fillWidth: true
                        color: Material.foreground
                        text: qsTr(comboBoxCurrentText)
                        Layout.alignment: Qt.AlignCenter
                        horizontalAlignment: Text.Center
                    }

                    Image {
                        id: succesAddElectricRate
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 150
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignCenter
                        source: "../images/tick.svg"
                    }

                    ColorOverlay {
                        anchors.fill: succesAddElectricRate
                        source: succesAddElectricRate
                        color: Material.accent
                    }

                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        id: nextButton
                        text: qsTr("Next")
                        Layout.preferredWidth: 250
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            if(historyView == true){
                                pageStack.pop()
                                pageStack.pop()
                                pageStack.pop()
                            }else{
                                pageStack.pop()
                                pageStack.pop()
                            }
                        }
                    }
                }
            }

            BusyOverlay {
                id: busyOverlay
            }
        }
    }
}
