import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0


QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['ALARM_TYPE'] = []
        container['ALARM_TYPE'][AntintrusionAlarm.Antipanic] = qsTr("panic")
        container['ALARM_TYPE'][AntintrusionAlarm.Intrusion] = qsTr("intrusion detection")
        container['ALARM_TYPE'][AntintrusionAlarm.Technical] = qsTr("technical")
        container['ALARM_TYPE'][AntintrusionAlarm.Tamper] = qsTr("anti-tampering")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
