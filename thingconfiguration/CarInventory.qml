import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQml 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import QtGraphicalEffects 1.15

import "../components"
import "../delegates"

Page{
    id: root
    signal done(var selectedCar)
    signal back()

    header: NymeaHeader {
        id: header
        text: qsTr("Car list")
        backButtonVisible: true
        onBackPressed: root.back()
    }

    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }


    ThingClassesProxy{
        id: thingClassesProxy
        engine: _engine
        filterInterface: "electricvehicle"
        includeProvidedInterfaces: true
        groupByInterface: true
    }

    QtObject {
        id: d
        property var vendorId: null
        property ThingDescriptor thingDescriptor: null
        property var discoveryParams: []
        property string thingName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property var name: ""
        property var params: []
        property var states: []
        property var settings: []
        property var attr: []


        function updateThing(thing) {

            for(var i = 0; i < d.states.length; i++){
                thing.executeAction( d.states[i].name, [{ paramName: d.states[i].name , value: d.states[i].value }])

            }

            for (var j = 0; j < d.settings.length; j++){
                engine.thingManager.setThingSettings(thing.id, [{ paramTypeId: d.settings[j].paramTypeId , value: d.settings[j].value }])
            }
                engine.thingManager.editThing(thing.id, d.name)

            pageStack.push(resultsPage, {thing: thing})


        }
    }




    Flickable{
        clip: true
        id: inventoryScroller
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        contentHeight: inventory.height
        contentWidth: app.width


        ColumnLayout{
            id: inventory
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: app.margins
            anchors.margins: app.margins
            Repeater{
                id: addCarRepeater
                Layout.fillWidth: true
                Layout.topMargin: 5
                model: 1
                delegate: ItemDelegate{
                    Layout.fillWidth: true
                    contentItem: ColumnLayout{
                        id: carRepeaterLayout
                        Layout.fillWidth: true

                        VerticalDivider
                        {
                            Layout.fillWidth: true
                            dividerColor: Material.accent
                        }

                        ConsolinnoItemDelegate{
                            id: addCardelegate
                            iconName: "add"
                            iconColor: Material.foreground
                            Layout.fillWidth: true
                            text: qsTr("Add new car")
                            progressive: false
                            onClicked:{

                                for (var i = 0; i<thingClassesProxy.count; i++){
                                    if (thingClassesProxy.get(i).id.toString() === "{dbe0a9ff-94ba-4a94-ae52-51da3f05c717}"  ){
                                        var page = pageStack.push("../thingconfiguration/AddGenericCar.qml" , {thingClass: thingClassesProxy.get(i)})
                                        page.done.connect(function(attr){
                                            pageStack.pop()
                                        })
                                        page.aborted.connect(function(){
                                            pageStack.pop()
                                        })
                                    }
                                }




                            }

                        }
                        VerticalDivider
                        {
                            Layout.fillWidth: true
                            dividerColor: Material.accent
                        }
                    }
                }
            }

            Repeater{
                id: optimizerRepeater
                Layout.fillWidth: true
                model: evProxy
                delegate: ItemDelegate{
                    id: optimizerInputs
                    Layout.fillWidth: true
                    contentItem: ColumnLayout{
                        Layout.fillWidth: true
                        objectName: "optimizerRepeater_" + index.toString()
                        RowLayout{

                            ConsolinnoItemDelegate{

                                Layout.fillWidth: true
                                Layout.preferredWidth: app.width/1.5
                                progressive: false
                                text: evProxy.get(index) ? evProxy.get(index).name : ""
                                onClicked: {
                                    root.done(evProxy.get(index))
                                    pageStack.pop()
                                }

                            }

                            ConsolinnoItemDelegate{
                                Layout.fillWidth: true
                                primetextElide: Text.ElideNone
                                text: qsTr("edit")
                                iconName: "edit"
                                iconColor: Material.foreground
                                progressive: false
                                onClicked: {
                                    pageStack.push(carData, {thing: evProxy.get(index)})
                                }

                            }


                        }

                        VerticalDivider
                        {
                            dividerColor: Material.accent
                            Layout.fillWidth: true
                        }

                    }

                }

            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            property var thing
            header: NymeaHeader {
                text: qsTr("Reconfigure " + thing.name)
                onBackPressed: pageStack.pop()
            }


            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Thing reconfigured!")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("All done. You can now start using %1.").arg(thing.name)
                }



                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done(thing)
                        pageStack.pop()
                        pageStack.pop()
                        pageStack.pop()
                    }
                }
            }
        }
    }




    Component
    {
        id: carData
        SettingsPageBase{
            property var thing
            title: thing ? thing.name : ""

            ColumnLayout{


                Repeater{
                    id: customRepeater
                    Layout.fillWidth: true
                    property var attributes: ({})
                    // if you want to add atribute:
                    // add one in the model
                    model:[

                        {id: "name", name: "Name: ", displayName: qsTr("Name: "), component: nameComponent, type: "name", Uuid: "", info: ""  },
                        {id: "capacity", name: "Battery capacity", displayName: qsTr("Battery capacity"),component: capacityComponent, type: "setting", Uuid: "57f36386-dd71-4ab0-8d2f-8c74a391f90d", info: "Capacity.qml"  },
                        {id: "minChargingCurrent", name: "Minimum charging current", displayName: qsTr("Minimum charging current"), component: minimumChargingCurrentComponent, type: "setting", Uuid: "0c55516d-4285-4d02-8926-1dae03649e18", info: "MinimumChargingCurrent.qml"},
                        {id: "maxChargingLimit", name: "Maximum charging limit" , displayName: qsTr("Maximum charging limit"), component: maximumAllowedChargingLimitComponent, type: "attr", Uuid: "", info: "MaximumAllowedChargingLimit.qml" },


                    ]

                    delegate: ItemDelegate
                    {
                        id: attribute
                        Layout.fillWidth: true

                        contentItem: ColumnLayout{
                            id: contentItemColumn
                            Layout.fillWidth: true
                            spacing: 0

                            Row{
                                Layout.fillWidth: true
                                Label{
                                    id: customRepeaterModelName
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignLeft
                                    text: modelData.displayName

                                }

                                InfoButton{
                                    property var infoPage: modelData.info
                                    visible: modelData.info ? true : false
                                    push: infoPage
                                    stack: pageStack
                                    anchors.left: customRepeaterModelName.right
                                    anchors.leftMargin:  5
                                }



                            }
                            // define the case in the Loader
                            Loader{
                                id: paramLoader

                                Binding{
                                    target: paramLoader.item
                                    property: "thing"
                                    value: thing
                                }

                                Layout.fillWidth: true
                                Layout.rightMargin: 0
                                sourceComponent: {
                                    switch(modelData.id){
                                    case "maxChargingLimit":
                                    {
                                        return maximumAllowedChargingLimitComponent
                                    }
                                    case "minChargingCurrent":
                                    {
                                        return minimumChargingCurrentComponent
                                    }
                                    case "capacity":
                                    {
                                        return capacityComponent
                                    }
                                    case "name":
                                    {
                                        return nameComponent
                                    }

                                    }

                                }
                            }



                        }
                    }

                }

                // individual Components for the different attributes
                // and build a component
                Component{
                    id: maximumAllowedChargingLimitComponent
                    RowLayout{
                        property var thing
                        Layout.fillWidth: true
                        Slider
                        {
                            id: maximumChargingSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            from: 0
                            to: 100
                            stepSize: 1
                            value: 100

                            onPositionChanged:{
                                customRepeater.attributes["maxChargingLimit"] = value
                            }

                        }
                        Label{

                            Layout.fillWidth: true
                            Layout.maximumWidth: 40
                            Layout.rightMargin: 0
                            horizontalAlignment: Text.AlignRight
                            id: maximumChargingLimitLabel
                            text: maximumChargingSlider.value + "%"
                        }

                    }

                }

                Component{
                    id: minimumChargingCurrentComponent

                    RowLayout{
                        property var thing
                        Layout.fillWidth: true
                        Slider
                        {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            id: minimumChargingCurrentSlider
                            from: 6
                            to: 16
                            stepSize: 1
                            value: thing ?  thing.stateByName("minChargingCurrent").value : 6

                            onPositionChanged:{
                                customRepeater.attributes["minChargingCurrent"] = value
                            }

                        }

                        Label{
                            Layout.preferredWidth: 40
                            Layout.rightMargin: 0
                            horizontalAlignment: Text.AlignRight
                            id: minimumChargingCurrentLabel
                            text: minimumChargingCurrentSlider.value + " A"
                        }

                    }

                }

                Component{
                    id: capacityComponent
                    RowLayout{
                        property var thing
                        Layout.fillWidth: true
                        // at some time replace this one
                        RowLayout{
                            Layout.alignment: Qt.AlignHCenter
                            NymeaSpinBox
                            {

                                Layout.maximumWidth: 150

                                value: thing ? thing.stateByName("capacity").value : 0
                                id: capacitySpinbox
                                from: 0
                                to: 100

                                onValueChanged:{

                                    if (value >= 0){
                                        customRepeater.attributes["capacity"] = value
                                    }else{
                                        value = 0
                                    }

                                }



                            }

                            Label{
                                Layout.preferredWidth: 20
                                id: capacityComponentLabel
                                text: " kWh"
                            }
                        }

                    }

                }


                Component{
                    id: nameComponent
                    RowLayout{
                        property var thing
                        TextField {
                            id: nameTextField
                            text: thing ? thing.name : ""
                            Layout.fillWidth: true
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            onTextEdited: {
                                customRepeater.attributes["name"] = nameTextField.text
                            }
                        }


                    }

                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    Image{
                        id: deleteButton
                        source: "../images/delete.svg"
                        Layout.maximumWidth: 35
                        Layout.maximumHeight: 35
                        Layout.leftMargin: app.margins
                        Layout.bottomMargin: 10
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft
                        MouseArea{
                            width: parent.width
                            height: parent.height
                            onClicked:{       
                                engine.thingManager.removeThing(thing.id)
                                pageStack.pop()
                            }

                        }
                        ColorOverlay{
                            width: parent.width
                            height: parent.height
                            source: deleteButton
                            color: Material.foreground
                        }
                    }
                    Label{
                        text: qsTr("delete")
                    }
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Save")
                    onClicked: {
                        var states = []
                        var settings = []
                        var attrs = []

                        for(var i = 0; i < customRepeater.count; i++)
                        {
                            var state   = {}
                            var setting = {}
                            var attr   = {}

                            var attribute = customRepeater.model[i]
                            if (attribute.type === "state")
                            {

                                state.value = customRepeater.attributes[attribute.id]
                                state.name = attribute.id
                                states.push(state)

                            }else if(attribute.type === "setting"){

                                setting.paramTypeId = attribute.Uuid

                                setting.value = customRepeater.attributes[attribute.id]
                                settings.push(setting)

                            }else if(attribute.type === "attr"){

                                attr.id = attribute.id
                                attr.value = customRepeater.attributes[attribute.id]
                                attrs.push(attr)
                            }else if(attribute.type === "name"){

                                if ("name" in customRepeater.attributes){
                                    d.name = customRepeater.attributes[attribute.id]
                                }else{
                                    d.name = thing.name
                                }

                            }



                        }

                        d.settings = settings
                        d.states = states
                        d.attr = attrs
                        d.updateThing( thing );

                    }
                }

            }
        }

    }


}


