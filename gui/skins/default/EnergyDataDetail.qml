import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0
import BtObjects 1.0

import "js/Stack.js" as Stack

Page {
    property variant family: null

    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    showSystemsButton: true
    text: qsTr("energy consumption")
    source: "images/bg2.jpg"


    QtObject {
        id: privateProps
        property bool showCurrency: false
    }

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

        Loader {
            id: buttonRowLoader
            sourceComponent: energiesCounters.hasRate() ? buttonRowComponent : undefined
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 3
                right: divisorLine.right
            }
        }

        Component {
            id: buttonRowComponent
            Row {
                UbuntuLightText {
                    text: qsTr("value")
                    color: "white"
                    anchors.verticalCenter: moneyButton.verticalCenter
                    font.pixelSize: 14
                }

                Item {
                    width: 15
                    height: moneyButton.height
                }

                ButtonThreeStates {
                    id: moneyButton
                    defaultImage: "images/common/btn_66x35.svg"
                    pressedImage: "images/common/btn_66x35_P.svg"
                    selectedImage: "images/common/btn_66x35_S.svg"
                    shadowImage: "images/common/btn_shadow_66x35.svg"
                    text: energiesCounters.getCurrencySymbol()
                    font.pixelSize: 14
                    status: privateProps.showCurrency === true ? 1 : 0
                    onClicked: privateProps.showCurrency = true
                }
                ButtonThreeStates {
                    id: consumptionButton
                    defaultImage: "images/common/btn_66x35.svg"
                    pressedImage: "images/common/btn_66x35_P.svg"
                    selectedImage: "images/common/btn_66x35_S.svg"
                    shadowImage: "images/common/btn_shadow_66x35.svg"
                    text: qsTr("units")
                    font.pixelSize: 14
                    status: privateProps.showCurrency === false ? 1 : 0
                    onClicked: privateProps.showCurrency = false
                }
            }
        }

        SvgImage {
            id: divisorLine
            source: "images/energy/linea.svg"
            anchors {
                top: buttonRowLoader.bottom
                topMargin: parent.height / 100 * 3
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
                measureType: privateProps.showCurrency === true ? EnergyData.Currency : EnergyData.Consumption
                onClicked: Stack.pushPage("EnergyDataGraph.qml", {"energyData": itemObject})
                maxValue: {
                    if (parseInt(family.objectKey) !== EnergyFamily.Custom) {
                        return energiesCounters.getMaxValue()
                    }

                    var monthItem = energiesCounters.getObject(index).getValue(EnergyData.CumulativeMonthValue,
                                                                           new Date(), EnergyData.Consumption)

                    if (monthItem.isValid && monthItem.goalEnabled)
                        return Math.max(monthItem.consumptionGoal, monthItem.value)

                    return -1
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

    ObjectModel {
        id: energiesCounters
        function getMaxValue() {
            var max = 0
            for (var i = 0; i < count; i+=1) {
                var monthItem = getObject(i).getValue(EnergyData.CumulativeMonthValue,
                                                      new Date(), EnergyData.Consumption)
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
