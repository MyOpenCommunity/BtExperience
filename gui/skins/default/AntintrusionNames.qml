import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['ALARM_TYPE'] = []
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Antipanic] = qsTr("panic")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Intrusion] = qsTr("intrusion detection")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Technical] = qsTr("technical")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Tamper] = qsTr("anti-tampering")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
