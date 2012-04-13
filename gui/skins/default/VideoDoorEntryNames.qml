import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['A'] = []
        Script.container['A'][0] = qsTr("")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
