import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0
import BtExperience 1.0

QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['REBOOT'] = []
        container['REBOOT'][0] = qsTr("Pressing ok will cause a device reboot in a few moments.\nContinue?")

        container['CONFIG'] = []
        container['CONFIG'][PlatformSettings.Dhcp] = qsTr("DHCP")
        container['CONFIG'][PlatformSettings.Static] = qsTr("Static IP address")

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

        container['LANGUAGE'] = []
        container['LANGUAGE']["it"] = qsTr("Italian")
        container['LANGUAGE']["en"] = qsTr("English")
        container['LANGUAGE']["fr"] = qsTr("French")

        container['KEYBOARD'] = []
        container['KEYBOARD']["it_bticino"] = qsTr("Italian")
        container['KEYBOARD']["en_gb_bticino"] = qsTr("English (GB)")
        container['KEYBOARD']["fr_bticino"] = qsTr("French")

        container['CURRENCY'] = []
        container['CURRENCY']["CHF"] = qsTr("Swiss franc")
        container['CURRENCY']["EUR"] = qsTr("Euro €")
        container['CURRENCY']["GBP"] = qsTr("British pound £")
        container['CURRENCY']["JPY"] = qsTr("Japanese yen ¥")
        container['CURRENCY']["USD"] = qsTr("U.S. dollar $")

        container['SKIN'] = []
        container['SKIN'][GuiSettings.Clear] = qsTr("Clear")
        container['SKIN'][GuiSettings.Dark] = qsTr("Dark")

        // TODO from here on, change  wrt to model developments

        container['PASSWORD'] = []
        container['PASSWORD'][false] = qsTr("Disable")
        container['PASSWORD'][true] = qsTr("Enable")

        container['BEEP'] = []
        container['BEEP'][true] = qsTr("Enable")
        container['BEEP'][false] = qsTr("Disable")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
