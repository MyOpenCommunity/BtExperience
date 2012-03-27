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
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
