import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea 1.0

import "../wizards"
import "../components"

EmptyViewPlaceholder {
    id: root

    title: qsTr("Your %1 is not set up yet.").arg(Configuration.deviceName)
    text: qsTr("Please complete the setup wizard or manually configure your devices.")
    imageSource: "/ui/images/leaf.svg"
    buttonText: qsTr("Start setup")
    onButtonClicked: {
        wizardController.startSetup()
    }

    WizardController {
        id: wizardController
    }

}
