/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
            if (energyItem.family === EnergyData.Electricity && energyItem.value < 1.0) {
                // bug #20716, visualize values less than 1 kwh as wh, strip
                // initial "k" from measureUnit
                return (energyItem.value * 1000).toFixed(0) + " " + energyItem.measureUnit.substr(1)
            }
            return energyItem.value.toFixed(energyItem.decimals) + " " + energyItem.measureUnit;
        }
        return ""
    }

    function formatCurrency(energyItem) {
        if (energyItem.isValid) {
            return energyItem.value.toFixed(energyItem.decimals) + " " + energyItem.measureUnit;
        }
        return ""
    }

    function getColor(energyItem) {
        // returns a color showing how many threshold has been exceeded
        if (energyItem.isValid) {
            if (energyItem.thresholdLevel === 0)
                return "grey"
            if (energyItem.thresholdLevel === 1)
                return "orange"
            if (energyItem.thresholdLevel === 2)
                return "red"
        }
        return "grey"
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

