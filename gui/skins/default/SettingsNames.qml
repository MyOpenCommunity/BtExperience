import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['NETWORK'] = []
        Script.container['NETWORK'][Network.Dhcp] = qsTr("DHCP")
        Script.container['NETWORK'][Network.Static] = qsTr("static IP address")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
