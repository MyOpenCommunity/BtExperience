import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0

QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['A'] = []
        container['A'][0] = qsTr("")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
