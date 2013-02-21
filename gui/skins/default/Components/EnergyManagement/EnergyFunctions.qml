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

    function isEnergyMonthValid(d) {
        var year = d.getFullYear()
        var month = d.getMonth()

        var currentDate = new Date()
        var cur_year = currentDate.getFullYear()
        var cur_month = currentDate.getMonth()

        if (year === cur_year && month <= cur_month)
            return true

        if (year === cur_year - 1 && month > cur_month)
            return true

        return false
    }

    function isEnergyYearValid(d) {
        var year = d.getFullYear()
        var cur_year = new Date().getFullYear()

        if (year <= cur_year && year >= cur_year - 12)
            return true

        return false
    }

    function isEnergyDayValid(d) {
        var currentDate = new Date()
        if (d.getTime() > currentDate.getTime())
            return false

        var year = d.getFullYear()
        var month = d.getMonth()
        var day = d.getDate()

        var cur_year = currentDate.getFullYear()
        var cur_month = currentDate.getMonth()
        var cur_day = currentDate.getDate()

        if (year === cur_year)
            return true
        if (year === cur_year -1 && month > cur_month)
            return true

        if (year === cur_year -1 && month === cur_month && day > cur_day)
            return true

        return false
    }

    function automaticUpdatesEnabled(screen_state) {
        switch (screen_state) {
        case ScreenState.ScreenOff:
        case ScreenState.Screensaver:
        case ScreenState.PasswordCheck:
        case ScreenState.Calibration:
        case ScreenState.ForcedNormal:
        {
            return false;
        }
        case ScreenState.Normal:
        case ScreenState.Freeze:
        {
            return true;
        }
        }
    }
}

