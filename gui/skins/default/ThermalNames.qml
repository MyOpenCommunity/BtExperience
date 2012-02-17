import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['SEASON'] = []
        Script.container['SEASON'][ThermalControlUnit99Zones.Summer] = qsTr("estate")
        Script.container['SEASON'][ThermalControlUnit99Zones.Winter] = qsTr("inverno")

        Script.container['PROBE_STATUS'] = []
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Auto] = qsTr("auto")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Antifreeze] = qsTr("antigelo")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Manual] = qsTr("manuale")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Off] = qsTr("off")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Unknown] = qsTr("--")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
