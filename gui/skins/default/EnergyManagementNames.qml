import QtQuick 1.1
import BtObjects 1.0

import "js/array.js" as Script


QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['ENERGY_TYPE'] = []
        container['ENERGY_UNIT'] = []

        // "normal" strings
        container['ENERGY_TYPE']["Consumption Management"] = qsTr("Consumption Management")

        // EnergyType
        container['ENERGY_TYPE'][EnergyData.Electricity] = qsTr("Electricity")
        container['ENERGY_TYPE'][EnergyData.Water] = qsTr("Water")
        container['ENERGY_TYPE'][EnergyData.Gas] = qsTr("Gas")
        container['ENERGY_TYPE'][EnergyData.HotWater] = qsTr("HotWater")
        container['ENERGY_TYPE'][EnergyData.Heat] = qsTr("Heat")
//        container['ENERGY_TYPE'][EnergyData.???] = qsTr("Liquid Gas")

        // EnergyUnit
        container['ENERGY_UNIT'][EnergyData.Electricity] = qsTr("kWh")
        container['ENERGY_UNIT'][EnergyData.Water] = qsTr("l")
        container['ENERGY_UNIT'][EnergyData.Gas] = qsTr("l")
        container['ENERGY_UNIT'][EnergyData.HotWater] = qsTr("l")
        container['ENERGY_UNIT'][EnergyData.Heat] = qsTr("cal")
//        container['ENERGY_UNIT'][EnergyData.???] = qsTr("???s")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
