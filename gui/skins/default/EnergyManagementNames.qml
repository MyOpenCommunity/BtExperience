import QtQuick 1.1
import BtObjects 1.0

import "js/array.js" as Script


QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['ENERGY_TYPE'] = []
        container['STOP_GO_STATUS'] = []

        // stop&go status translations
        container['STOP_GO_STATUS'][StopAndGo.Unknown] = qsTr("Unknown")
        container['STOP_GO_STATUS'][StopAndGo.Closed] = qsTr("Closed")
        container['STOP_GO_STATUS'][StopAndGo.Opened] = qsTr("Opened")
        container['STOP_GO_STATUS'][StopAndGo.Locked] = qsTr("Locked")
        container['STOP_GO_STATUS'][StopAndGo.ShortCircuit] = qsTr("ShortCircuit")
        container['STOP_GO_STATUS'][StopAndGo.GroundFail] = qsTr("GroundFail")
        container['STOP_GO_STATUS'][StopAndGo.Overtension] = qsTr("Overtension")

        // "normal" strings
        container['ENERGY_TYPE']["Consumption Management"] = qsTr("Consumption Management")

        // EnergyType
        container['ENERGY_TYPE'][EnergyData.Electricity] = qsTr("Electricity")
        container['ENERGY_TYPE'][EnergyData.Water] = qsTr("Water")
        container['ENERGY_TYPE'][EnergyData.Gas] = qsTr("Gas")
        container['ENERGY_TYPE'][EnergyData.HotWater] = qsTr("HotWater")
        container['ENERGY_TYPE'][EnergyData.Heat] = qsTr("Heat")
//        container['ENERGY_TYPE'][EnergyData.???] = qsTr("Liquid Gas")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
