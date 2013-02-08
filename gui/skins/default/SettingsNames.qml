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

        container['AUTO_UPDATE'] = []
        container['AUTO_UPDATE'][true] = qsTr("Enabled")
        container['AUTO_UPDATE'][false] = qsTr("Disabled")

        container['LANGUAGE'] = []
        container['LANGUAGE']["it"] = qsTr("Italian")
        container['LANGUAGE']["en"] = qsTr("English")
        container['LANGUAGE']["fr"] = qsTr("French")

        container['KEYBOARD'] = []
        container['KEYBOARD']["it_bticino"] = qsTr("Italian")
        container['KEYBOARD']["en_bticino"] = qsTr("English")
        container['KEYBOARD']["fr_bticino"] = qsTr("French")

        container['SKIN'] = []
        container['SKIN'][HomeProperties.Clear] = qsTr("Clear")
        container['SKIN'][HomeProperties.Dark] = qsTr("Dark")

        container['PASSWORD'] = []
        container['PASSWORD'][false] = qsTr("Disable")
        container['PASSWORD'][true] = qsTr("Enable")

        container['BEEP'] = []
        container['BEEP'][true] = qsTr("Enabled")
        container['BEEP'][false] = qsTr("Disabled")

        container['HANDS_FREE'] = []
        container['HANDS_FREE'][true] = qsTr("Enabled")
        container['HANDS_FREE'][false] = qsTr("Disabled")

        container['AUTO_OPEN'] = []
        container['AUTO_OPEN'][true] = qsTr("Enabled")
        container['AUTO_OPEN'][false] = qsTr("Disabled")

        container['RING_EXCLUSION'] = []
        container['RING_EXCLUSION'][true] = qsTr("Enabled")
        container['RING_EXCLUSION'][false] = qsTr("Disabled")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
