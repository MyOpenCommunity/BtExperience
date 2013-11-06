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
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation


/**
  \ingroup EnergyDataSystem

  \brief A page showing all lines belonging to a family.

  When navigating in the energy system, this page shows all lines belonging
  to a family. Clicking on an item is possible to see details about that
  particular line.
  */
Page {
    /** the family I am navigating */
    property variant family: null

    /**
      Called when systems button on navigation bar is clicked.
      Navigates back to system page.
      */
    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    /**
      Called when settings button on navigation bar is clicked.
      Navigates to energy settings.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.ENERGY_SETTINGS})
    }

    showSystemsButton: true
    showSettingsButton: true
    text: qsTr("energy consumption")
    source: "images/background/energy.jpg"

    SvgImage {
        id: header
        source: "images/energy/bg_titolo.svg"
        anchors {
            top: navigationBar.top
            left: parent.left
            leftMargin: 130
        }

        SvgImage {
            function getFamilyIcon(familyType) {
                switch (familyType) {
                case EnergyFamily.Water:
                    return "images/energy/ico_water_p.svg"
                case EnergyFamily.Gas:
                    return "images/energy/ico_gas_p.svg"
                case EnergyFamily.DomesticHotWater:
                    return "images/energy/ico_hot_water_p.svg"
                case EnergyFamily.HeatingCooling:
                    return "images/energy/ico_heating_p.svg"
                case EnergyFamily.Electricity:
                    return "images/energy/ico_electricity_p.svg"
                default:
                    return ""
                }
            }
            source: getFamilyIcon(parseInt(family.objectKey))
            anchors {
                verticalCenter: parent.verticalCenter
                right: titleText.left
                rightMargin: 5
            }
        }

        UbuntuLightText {
            id: titleText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: parent.width / 100 * 5
            }

            font.pixelSize: 28
            text: family.name
            color: "white"
        }
    }

    SvgImage {
        id: bg_graph
        source: "images/energy/bg_grafico.svg"
        anchors {
            top: header.bottom
            topMargin: 4
            left: header.left
        }

        SvgImage {
            id: divisorLine
            source: "images/energy/linea.svg"
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 14.5
                horizontalCenter: parent.horizontalCenter
            }
        }

        CardView {
            id: columnView
            anchors {
                // TODO: I'd like to center the arrows in the 'gray' area on the
                // left/right of the EnergyDataDelegate items.
                // However using the current code is too difficult (long), so we
                // avoid wasting time and we hardocode the left/right margins.
                bottom: parent.bottom
                bottomMargin: 20
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            height: 315
            delegate: EnergyDataDelegate {
                id: delegate
                itemObject: energiesCounters.getObject(index)
                measureType: EnergyData.Consumption
                onTouched: Stack.pushPage("EnergyDataGraph.qml", {"energyData": itemObject})
                maxValue: {
                    if (parseInt(family.objectKey) !== EnergyFamily.Custom) {
                        return energiesCounters.getMaxValue()
                    }

                    var monthItem = consumptionObj.item

                    if (monthItem.isValid && monthItem.goalEnabled)
                        return Math.max(monthItem.consumptionGoal, monthItem.value)

                    return -1
                }

                EnergyItemObject {
                    id: consumptionObj
                    energyData: energiesCounters.getObject(index)
                    valueType: EnergyData.CumulativeMonthValue
                    date: new Date()
                    measureType: EnergyData.Consumption
                }
            }
            delegateSpacing: 40
            visibleElements: 4
            model: energiesCounters
        }
    }

    EnergyManagementNames {
        id: translations
    }

    Component {
        id: energyItemObject
        EnergyItemObject {
            valueType: EnergyData.CumulativeMonthValue
            date: new Date()
            measureType: EnergyData.Consumption
        }
    }

    ObjectModel {
        id: energiesCounters

        function getMaxValue() {
            var max = 0
            for (var i = 0; i < count; i+=1) {
                var consumption = energyItemObject.createObject(energiesCounters, {
                                                                    energyData: getObject(i),
                                                                    valueType: EnergyData.CumulativeMonthValue,
                                                                    date: new Date(),
                                                                    measureType: EnergyData.Consumption,
                                                                });
                var monthItem = consumption.item
                if (monthItem.isValid && monthItem.value > max)
                    max = monthItem.value

                if (monthItem.consumptionGoal > max)
                    max = monthItem.consumptionGoal
            }
            return max
        }

        function hasRate() {
            for (var i = 0; i < count; i+=1) {
                if (getObject(i).rate !== null)
                    return true
            }
            return false
        }

        function getCurrencySymbol() {
            // We are assuming that the currencySymbol for a family is always
            // the same.
            for (var i = 0; i < count; i+=1) {
                var rate = getObject(i).rate
                if (rate !== null)
                    return rate.currencySymbol
            }
            return ""
        }

        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: family.objectKey}]
    }
}
