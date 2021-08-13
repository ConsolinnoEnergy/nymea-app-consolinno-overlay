/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root


    readonly property bool loading: engine.thingManager.fetchingData

    QtObject {
        id: d
        property var currentWizard: null

        function setup(showFinalPage) {

            print("Setup. Installed energy meters:", energyMetersProxy.count, "EV Chargers:", evChargersProxy.count)

            if (energyMetersProxy.count === 0) {
                d.currentWizard = pageStack.push("/ui/wizards/SetupEnergyMeterWizard.qml")
                d.currentWizard.done.connect(function() {setup(true)})
                return
            }

            if (evChargersProxy.count === 0) {
                d.currentWizard = pageStack.push("/ui/wizards/SetupEVChargerWizard.qml")
                d.currentWizard.done.connect(function() {setup(true)})
                return
            }

            if (showFinalPage) {
                var page = pageStack.push("/ui/wizards/WizardComplete.qml")
                page.done.connect(function() {exitWizard()})
            }
        }

        function exitWizard() {
            pageStack.pop(d.currentWizard, StackView.Immediate)
            pageStack.pop()
        }
    }

    onLoadingChanged: {
        if (!loading) {
            d.setup(false)
        }
    }

    ThingsProxy {
        id: energyMetersProxy
        engine: _engine
        shownInterfaces: ["energymeter"]
    }

    ThingsProxy {
        id: evChargersProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: /*engine.thingManager.things.count === 0 &&*/ !engine.thingManager.fetchingData
        title: qsTr("Welcome to %1!").arg(Configuration.systemName)
        text: qsTr("Start with adding your appliances.")
        imageSource: "qrc:/ui/images/leaf.svg"
        buttonText: qsTr("Configure your leaflet")
    }

    Label {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Style.margins
        }
        text: "Demo view. Consolinno energy related views will be added here."
        font: Style.extraSmallFont
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}
