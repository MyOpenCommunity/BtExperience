import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['CONFIG'] = []
        Script.container['CONFIG'][Network.Dhcp] = qsTr("DHCP")
        Script.container['CONFIG'][Network.Static] = qsTr("static IP address")

        Script.container['STATE'] = []
        Script.container['STATE'][Network.Enabled] = qsTr("Connect")
        Script.container['STATE'][Network.Disabled] = qsTr("Disconnect")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
