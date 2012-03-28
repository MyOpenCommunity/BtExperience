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

        Script.container['AUTO_UPDATE'] = []
        Script.container['AUTO_UPDATE'][0] = qsTr("Enabled")
        Script.container['AUTO_UPDATE'][1] = qsTr("Disabled")

        Script.container['FORMAT'] = []
        Script.container['FORMAT'][0] = qsTr("12h")
        Script.container['FORMAT'][1] = qsTr("24h")

        Script.container['SCREEN_SAVER_TYPE'] = []
        Script.container['SCREEN_SAVER_TYPE'][0] = qsTr("None")
        Script.container['SCREEN_SAVER_TYPE'][1] = qsTr("Image")
        Script.container['SCREEN_SAVER_TYPE'][2] = qsTr("Text")
        Script.container['SCREEN_SAVER_TYPE'][3] = qsTr("Date and Time")

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

        Script.container['SCREEN_SAVER_TIMEOUT'] = []
        Script.container['SCREEN_SAVER_TIMEOUT'][0] = qsTr("15 sec")
        Script.container['SCREEN_SAVER_TIMEOUT'][1] = qsTr("30 sec")
        Script.container['SCREEN_SAVER_TIMEOUT'][2] = qsTr("1 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][3] = qsTr("2 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][4] = qsTr("5 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][5] = qsTr("10 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][6] = qsTr("30 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][7] = qsTr("1 hour")

        // TODO when using an enum change accordingly
        Script.container['TIMEZONE'] = []
        Script.container['TIMEZONE'][-2] = qsTr("GMT -2")
        Script.container['TIMEZONE'][-1] = qsTr("GMT -1")
        Script.container['TIMEZONE'][0] = qsTr("GMT 0")
        Script.container['TIMEZONE'][1] = qsTr("GMT +1")
        Script.container['TIMEZONE'][2] = qsTr("GMT +2")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
