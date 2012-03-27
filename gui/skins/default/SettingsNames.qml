import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['CONFIG'] = []
        Script.container['CONFIG'][Platform.Dhcp] = qsTr("DHCP")
        Script.container['CONFIG'][Platform.Static] = qsTr("static IP address")

        Script.container['STATE'] = []
        Script.container['STATE'][Platform.Enabled] = qsTr("Connect")
        Script.container['STATE'][Platform.Disabled] = qsTr("Disconnect")

        Script.container['TURN_OFF_DISPLAY_LIST'] = []
        Script.container['TURN_OFF_DISPLAY_LIST'][0] = qsTr("15 sec")
        Script.container['TURN_OFF_DISPLAY_LIST'][1] = qsTr("30 sec")
        Script.container['TURN_OFF_DISPLAY_LIST'][2] = qsTr("1 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][3] = qsTr("2 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][4] = qsTr("5 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][5] = qsTr("10 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][6] = qsTr("30 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][7] = qsTr("1 hour")
        Script.container['TURN_OFF_DISPLAY_LIST'][8] = qsTr("never")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
