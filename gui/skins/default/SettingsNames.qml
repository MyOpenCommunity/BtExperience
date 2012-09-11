import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0
import BtExperience 1.0

QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['CONFIG'] = []
        container['CONFIG'][PlatformSettings.Dhcp] = qsTr("DHCP")
        container['CONFIG'][PlatformSettings.Static] = qsTr("static IP address")

        container['STATE'] = []
        container['STATE'][PlatformSettings.Enabled] = qsTr("Connect")
        container['STATE'][PlatformSettings.Disabled] = qsTr("Disconnect")

        container['SCREEN_SAVER_TYPE'] = []
        container['SCREEN_SAVER_TYPE'][GuiSettings.None] = qsTr("None")
        container['SCREEN_SAVER_TYPE'][GuiSettings.Image] = qsTr("Image")
        container['SCREEN_SAVER_TYPE'][GuiSettings.Text] = qsTr("Text")
        container['SCREEN_SAVER_TYPE'][GuiSettings.DateTime] = qsTr("Date and Time")
        container['SCREEN_SAVER_TYPE'][GuiSettings.Rectangles] = qsTr("Rectangles")
        container['SCREEN_SAVER_TYPE'][GuiSettings.Slideshow] = qsTr("Slideshow")

        container['TURN_OFF_DISPLAY_LIST'] = []
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_15] = qsTr("15 sec")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_30] = qsTr("30 sec")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_1] = qsTr("1 min")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_2] = qsTr("2 min")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_5] = qsTr("5 min")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_10] = qsTr("10 min")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_30] = qsTr("30 min")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Hours_1] = qsTr("1 hour")
        container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Never] = qsTr("never")

        container['SCREEN_SAVER_TIMEOUT'] = []
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_15] = qsTr("15 sec")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_30] = qsTr("30 sec")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_1] = qsTr("1 min")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_2] = qsTr("2 min")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_5] = qsTr("5 min")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_10] = qsTr("10 min")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_30] = qsTr("30 min")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Hours_1] = qsTr("1 hour")
        container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Never] = qsTr("never") // not really used

        container['AUTO_UPDATE'] = []
        container['AUTO_UPDATE'][true] = qsTr("Enabled")
        container['AUTO_UPDATE'][false] = qsTr("Disabled")

        container['FORMAT'] = []
        container['FORMAT'][GuiSettings.TimeFormat_12h] = qsTr("12h")
        container['FORMAT'][GuiSettings.TimeFormat_24h] = qsTr("24h")

        container['SUMMER_TIME'] = []
        container['SUMMER_TIME'][true] = qsTr("Enable")
        container['SUMMER_TIME'][false] = qsTr("Disable")

        container['LANGUAGE'] = []
        container['LANGUAGE'][GuiSettings.Italian] = qsTr("Italian")
        container['LANGUAGE'][GuiSettings.English] = qsTr("English")

        container['CURRENCY'] = []
        container['CURRENCY'][GuiSettings.CHF] = qsTr("CHF")
        container['CURRENCY'][GuiSettings.EUR] = qsTr("EUR")
        container['CURRENCY'][GuiSettings.GBP] = qsTr("GBP")
        container['CURRENCY'][GuiSettings.JPY] = qsTr("JPY")
        container['CURRENCY'][GuiSettings.USD] = qsTr("USD")

        container['SKIN'] = []
        container['SKIN'][GuiSettings.Clear] = qsTr("Clear")
        container['SKIN'][GuiSettings.Dark] = qsTr("Dark")

        // TODO from here on, change  wrt to model developments

        container['PASSWORD'] = []
        container['PASSWORD'][0] = qsTr("Enable")
        container['PASSWORD'][1] = qsTr("Disable")

        container['BEEP'] = []
        container['BEEP'][0] = qsTr("Enable")
        container['BEEP'][1] = qsTr("Disable")

        container['TIMEZONE'] = []
        container['TIMEZONE'][-2] = qsTr("GMT -2")
        container['TIMEZONE'][-1] = qsTr("GMT -1")
        container['TIMEZONE'][0] = qsTr("GMT 0")
        container['TIMEZONE'][1] = qsTr("GMT +1")
        container['TIMEZONE'][2] = qsTr("GMT +2")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
