import QtQuick 1.1
import BtObjects 1.0

QtObject {
    // A container of some energy common functions

    function getIcon(energyType, isPressed) {
        // We can't return a full icon path because in this way the path should be
        // relative to the module that use EnergyFunctions so the path can be
        // wrong.
        switch (energyType) {
        case EnergyData.Water:
            return isPressed ? "ico_water_p.svg" : "ico_water.svg"
        case EnergyData.Gas:
            return isPressed ? "ico_gas_p.svg" : "ico_gas.svg"
        case EnergyData.HotWater:
            return isPressed ? "ico_hot_water_p.svg" : "ico_hot_water.svg"
        case EnergyData.Heat:
            return isPressed ? "ico_heating_p.svg" : "ico_heating.svg"
        default:
            if (energyType !== EnergyData.Electricity)
                console.log("Unknown energy type (" + energyType + "), use default icon")
            return isPressed ?  "ico_electricity_p.svg" : "ico_electricity.svg"
        }
    }

    function formatValue(energyItem) {
        if (energyItem.isValid) {
            return energyItem.value.toFixed(energyItem.decimals) + " " + energyItem.measureUnit;
        }
        return ""
    }
}

