import QtQuick 2.5
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property string filterInterface: ""
    property var thingsListId: []
    property HemsManager hemsManager
    property Thing thingDevice

    header: NymeaHeader {
        text: qsTr("Set up new device")
        onBackPressed: {
            pageStack.pop();
        }
    }

    ThingsProxy {
        id: evChargersProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    Connections {
        target: engine.thingManager

        onThingAdded: {
            thingDevice = thing
        }
    }

    function startWizard(thingClass) {
        var page = pageStack.push(Qt.resolvedUrl("SetupWizard.qml"), {thingClass: thingClass});
        page.done.connect(function() {
            var thingPage = "";
            if(thingClass.interfaces.includes("heatpump")){
                thingPage = pageStack.push("../optimization/HeatingOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thingDevice.id), heatPumpThing: thingDevice})
                navigateBack(thingPage)
            }else if(thingClass.interfaces.includes("evcharger")){
                thingPage = pageStack.push("../optimization/EvChargerOptimization.qml", { hemsManager: hemsManager, chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thingDevice.id)})
                navigateBack(thingPage)
            }else if(thingClass.interfaces.includes("smartheatingrod")){
                thingPage = pageStack.push("../optimization/HeatingElementOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thingDevice.id), heatRodThing: thingDevice})
                navigateBack(thingPage)
            }else if(thingClass.interfaces.includes("solarinverter")){
                thingPage = pageStack.push("../optimization/PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration:  hemsManager.pvConfigurations.getPvConfiguration(thingDevice.id), thing: thingDevice, directionID: 1} )
                navigateBack(thingPage)
            }else{
                pageStack.pop(root, StackView.Immediate);
                pageStack.pop();
            }
        })
        page.aborted.connect(function() {
            pageStack.pop();
        })

        function navigateBack(thingPage){
            thingPage.done.connect(function() {
                pageStack.pop(root, StackView.Immediate);
                pageStack.pop();
            })
        }
    }

    ColumnLayout {
        anchors.fill: parent

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            columnSpacing: app.margins
            columns: Math.max(1, Math.floor(width / 250)) * 2
            visible: root.filterInterface == ""
            z: 1
            Label {
                text: qsTr("Vendor")
            }

            ComboBox {
                id: vendorFilterComboBox
                Layout.fillWidth: true
                textRole: "displayName"
                currentIndex: -1
                VendorsProxy {
                    id: vendorsProxy
                    vendors: engine.thingManager.vendors
                }
                model: ListModel {
                    id: vendorsFilterModel
                    dynamicRoles: true

                    Component.onCompleted: {
                        append({displayName: qsTr("All"), vendorId: ""})
                        for (var i = 0; i < vendorsProxy.count; i++) {
                            var vendor = vendorsProxy.get(i);
                            append({displayName: vendor.displayName, vendorId: vendor.id})
                        }
                        vendorFilterComboBox.currentIndex = 0
                    }
                }
            }
            Label {
                text: qsTr("Type")
            }

            ComboBox {
                id: typeFilterComboBox
                Layout.fillWidth: true
                textRole: "displayName"
                InterfacesSortModel {
                    id: interfacesSortModel
                    interfacesModel: InterfacesModel {
                        engine: _engine
                        shownInterfaces: app.supportedInterfaces
                        showUncategorized: false
                    }
                }
                model: ListModel {
                    id: typeFilterModel
                    ListElement { interfaceName: ""; displayName: qsTr("All") }

                    Component.onCompleted: {
                        for (var i = 0; i < interfacesSortModel.count; i++) {
                            append({interfaceName: interfacesSortModel.get(i), displayName: app.interfaceToString(interfacesSortModel.get(i))});
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight: Style.iconSize
                Layout.minimumWidth: Style.iconSize

                ColorIcon {
                    size: Style.iconSize
                    name: "../images/find.svg"
                }
            }

            TextField {
                id: displayNameFilterField
                Layout.fillWidth: true
            }
        }

        GroupedListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            bottomMargin: packagesFilterModel.count > 0 ? height : 0

            ThingsProxy {
                id: electrics
                engine: _engine
                shownInterfaces: ["dynamicelectricitypricing"]
            }
            ThingsProxy {
                id: gridSupport
                engine: _engine
                shownInterfaces: ["gridsupport"]
            }

            ThingsProxy {
                id: evCharger
                engine: _engine
                shownInterfaces: ["evcharger"]
            }

            ThingsProxy {
                id: heatPump
                engine: _engine
                shownInterfaces: ["heatpump"]
            }

            ThingClassesProxy {
                id: thingClassesProxyEvCharger
                engine: _engine
                filterInterface: "evcharger"
                includeProvidedInterfaces: true
            }

            ThingClassesProxy {
                id: thingClassesProxyHeatPump
                engine: _engine
                filterInterface: "heatpump"
                includeProvidedInterfaces: true
            }
            ThingClassesProxy {
                id: thingClassesProxyElectrics
                engine: _engine
                filterInterface: "dynamicelectricitypricing"
                includeProvidedInterfaces: true
            }

            model: ThingClassesProxy {
                id: thingClassesProxy
                engine: _engine
                filterInterface: root.filterInterface != "" ? root.filterInterface : typeFilterModel.get(typeFilterComboBox.currentIndex).interfaceName
                includeProvidedInterfaces: true
                filterVendorId: vendorFilterComboBox.currentIndex >= 0 ? vendorsFilterModel.get(vendorFilterComboBox.currentIndex).vendorId : ""
                filterString: displayNameFilterField.displayText
                groupByInterface: true
            }

            onContentYChanged: print("contentY", contentY, contentHeight, originY)

            delegate: NymeaItemDelegate {
                id: tingClassDelegate
                width: parent.width
                text: model.displayName
                subText: engine.thingManager.vendors.getVendor(model.vendorId).displayName
                iconName:{
                    for (let i = 0; i < thingClass.interfaces.length; i++) {
                        let icon = "";
                        let interfaceIcons = thingClass.interfaces[i];
                        switch (interfaceIcons) {
                        case "simpleheatpump":
                            if(Configuration.heatpumpIcon !== ""){
                                icon = "/ui/images/"+Configuration.heatpumpIcon
                            }else{
                                icon = "/ui/images/heatpump.svg"
                            }
                            return Qt.resolvedUrl(icon)
                        case "smartgridheatpump":
                            if(Configuration.heatpumpIcon !== ""){
                                icon = "/ui/images/"+Configuration.heatpumpIcon
                            }else{
                                icon = "/ui/images/heatpump.svg"
                            }
                            return Qt.resolvedUrl(icon)
                        case "pvsurplusheatpump":
                            if(Configuration.heatpumpIcon !== ""){
                                icon = "/ui/images/"+Configuration.heatpumpIcon
                            }else{
                                icon = "/ui/images/heatpump.svg"
                            }
                            return Qt.resolvedUrl(icon)
                        case "smartheatingrod":
                            if(Configuration.heatingRodIcon !== ""){
                                icon = "/ui/images/"+Configuration.heatingRodIcon
                            }else{
                                icon = "/ui/images/heating_rod.svg"
                            }
                            return Qt.resolvedUrl(icon)
                        case "energystorage":
                            if(Configuration.batteryIcon !== ""){
                                icon = "/ui/images/"+Configuration.batteryIcon
                            }else{
                                icon = "/ui/images/battery/battery-080.svg"
                            }
                            return Qt.resolvedUrl(icon)
                        case "evcharger":
                            if(Configuration.evchargerIcon !== ""){
                                icon = "/ui/images/"+Configuration.evchargerIcon
                                return Qt.resolvedUrl(icon)
                            }
                        case "solarinverter":
                            if(Configuration.inverterIcon !== ""){
                                icon = "/ui/images/"+Configuration.inverterIcon
                                return Qt.resolvedUrl(icon)
                            }
                        default:
                            return app.interfaceToIcon(interfaceIcons)
                        }
                    }
                }
                Image {
                    id: tileIcon
                    height: 24
                    width: 24
                    source: tingClassDelegate.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                }
                ColorOverlay {
                    anchors.fill: tileIcon
                    source: tileIcon
                    color: Style.consolinnoMedium
                }
                prominentSubText: false
                wrapTexts: false

                property ThingClass thingClass: thingClassesProxy.get(index)

                onClicked: {
                    root.startWizard(thingClass)
                }

                Component.onCompleted: {
                   if(evCharger.count === 1){
                       for(let i = 0; i < thingClassesProxyEvCharger.count; i++){
                           thingsListId[thingsListId.length] = thingClassesProxyEvCharger.get(i).id.toString()
                       }
                   }

                   if(heatPump.count === 1){
                       for(let i = 0; i < thingClassesProxyHeatPump.count; i++){
                           thingsListId[thingsListId.length] = thingClassesProxyHeatPump.get(i).id.toString()
                       }
                   }

                   if(gridSupport.count === 1){
                       thingsListId[thingsListId.length] = gridSupport.get(0).thingClass.id.toString()
                   }

                   if(electrics.count === 1){
                      thingsListId[thingsListId.length] = electrics.get(0).thingClass.id.toString()
                   }else{
                     thingsListId[thingsListId.length] = thingClassesProxyElectrics.get(0).id.toString()
                   }

                   thingClassesProxy.hiddenThingClassIds = thingsListId
               }

            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - Style.margins * 2
                opacity: packagesFilterModel.count > 0 &&
                         (thingClassesProxy.count == 0 || listView.contentY >= listView.contentHeight + listView.originY)
                         ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Style.shortAnimationDuration } }
                visible: opacity > 0
                title: qsTr("Looking for something else?")
                text: qsTr("Try to install more plugins.")
                imageSource: "/ui/images/save.svg"
                buttonText: qsTr("Install plugins")
                onButtonClicked: {
                    pageStack.push(Qt.resolvedUrl("/ui/system/PackageListPage.qml"), {filter: "nymea-plugin-"})
                }
                PackagesFilterModel {
                    id: packagesFilterModel
                    packages: engine.systemController.packages
                    nameFilter: "nymea-plugin-"
                }
            }
        }
    }

}
