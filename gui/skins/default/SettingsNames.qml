import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['CONFIG'] = []
        Script.container['CONFIG'][PlatformSettings.Dhcp] = qsTr("DHCP")
        Script.container['CONFIG'][PlatformSettings.Static] = qsTr("static IP address")

        Script.container['STATE'] = []
        Script.container['STATE'][PlatformSettings.Enabled] = qsTr("Connect")
        Script.container['STATE'][PlatformSettings.Disabled] = qsTr("Disconnect")

        Script.container['SCREEN_SAVER_TYPE'] = []
        Script.container['SCREEN_SAVER_TYPE'][GuiSettings.None] = qsTr("None")
        Script.container['SCREEN_SAVER_TYPE'][GuiSettings.Image] = qsTr("Image")
        Script.container['SCREEN_SAVER_TYPE'][GuiSettings.Text] = qsTr("Text")
        Script.container['SCREEN_SAVER_TYPE'][GuiSettings.DateTime] = qsTr("Date and Time")

        Script.container['TURN_OFF_DISPLAY_LIST'] = []
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_15] = qsTr("15 sec")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_30] = qsTr("30 sec")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_1] = qsTr("1 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_2] = qsTr("2 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_5] = qsTr("5 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_10] = qsTr("10 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_30] = qsTr("30 min")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Hours_1] = qsTr("1 hour")
        Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Never] = qsTr("never")

        Script.container['SCREEN_SAVER_TIMEOUT'] = []
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_15] = qsTr("15 sec")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_30] = qsTr("30 sec")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_1] = qsTr("1 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_2] = qsTr("2 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_5] = qsTr("5 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_10] = qsTr("10 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_30] = qsTr("30 min")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Hours_1] = qsTr("1 hour")
        Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Never] = qsTr("never") // not really used

        Script.container['AUTO_UPDATE'] = []
        Script.container['AUTO_UPDATE'][true] = qsTr("Enabled")
        Script.container['AUTO_UPDATE'][false] = qsTr("Disabled")

        Script.container['FORMAT'] = []
        Script.container['FORMAT'][GuiSettings.TimeFormat_12h] = qsTr("12h")
        Script.container['FORMAT'][GuiSettings.TimeFormat_24h] = qsTr("24h")

        Script.container['SUMMER_TIME'] = []
        Script.container['SUMMER_TIME'][true] = qsTr("Enable")
        Script.container['SUMMER_TIME'][false] = qsTr("Disable")

        Script.container['LANGUAGE'] = []
        Script.container['LANGUAGE'][GuiSettings.Italian] = qsTr("Italian")
        Script.container['LANGUAGE'][GuiSettings.English] = qsTr("English")

        Script.container['CURRENCY'] = []
        Script.container['CURRENCY'][GuiSettings.CHF] = qsTr("CHF")
        Script.container['CURRENCY'][GuiSettings.EUR] = qsTr("EUR")
        Script.container['CURRENCY'][GuiSettings.GBP] = qsTr("GBP")
        Script.container['CURRENCY'][GuiSettings.JPY] = qsTr("JPY")
        Script.container['CURRENCY'][GuiSettings.USD] = qsTr("USD")

        // TODO from here on, change  wrt to model developments

        Script.container['PASSWORD'] = []
        Script.container['PASSWORD'][0] = qsTr("Enable")
        Script.container['PASSWORD'][1] = qsTr("Disable")

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
