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

        container['AUTO_UPDATE'] = []
        container['AUTO_UPDATE'][true] = qsTr("Enabled")
        container['AUTO_UPDATE'][false] = qsTr("Disabled")

        container['SUMMER_TIME'] = []
        container['SUMMER_TIME'][true] = qsTr("Enable")
        container['SUMMER_TIME'][false] = qsTr("Disable")

        container['LANGUAGE'] = []
        container['LANGUAGE']["it"] = qsTr("Italian")
        container['LANGUAGE']["en"] = qsTr("English")
        container['LANGUAGE']["fr"] = qsTr("French")

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
