import QtQuick
import Nymea

CoNotification {
    id: root

    required property Thing thing

    visible: !ThingUtils.isConnected(thing)
    type: CoNotification.Type.Danger
    clickable: true
    messageTextFormat: Text.StyledText
    title: qsTr("Connection to \“Thing\” interrupted")
    message: qsTr("If the problem persists, try restarting the device. For more information, see the <u>log.</u>")
    onClicked: {
        let pageUrl = "../devicepages/ConsolinnoDeviceLogPage.qml";
        let signalStateType = root.thing.thingClass.stateTypes.findByName("signalStrength");
        let connectedStateType = root.thing.thingClass.stateTypes.findByName("connected");
        let stateTypes = [];
        if (signalStateType) {
            stateTypes.push(signalStateType.id);
        }
        if (connectedStateType) {
            stateTypes.push(connectedStateType.id);
        }
        pageStack.push(pageUrl, { thing: root.thing, filterTypeIds: stateTypes });
    }
}
