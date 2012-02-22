import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['ALARM_TYPE'] = []
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Antipanic] = qsTr("anti-panico")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Intrusion] = qsTr("intrusione")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Technical] = qsTr("tecnico")
        Script.container['ALARM_TYPE'][AntintrusionAlarm.Tamper] = qsTr("manomissione")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
