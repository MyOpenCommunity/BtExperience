import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0

import "js/Stack.js" as Stack


Page {
    id: page
    property variant energyData: undefined

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
            function getIcon(familyType) {
                familyType = familyType + 0
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
            source: getIcon(energyData.familyType)
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
            text: energyData.general ? qsTr("Overall") : energyData.name
            color: "white"
        }
    }

    Row {
        spacing: 4
        anchors {
            top: header.bottom
            topMargin: 4
            left: header.left
        }

        SvgImage {
            source: "images/energy/bg_grafico_time.svg"

            Row {
                id: timeButtonRow
                anchors {
                    top: buttonRow.top
                    left: divisorLine.left
                }

                ButtonThreeStates {
                    id: dayButton
                    font.pixelSize: 14
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("day")
                    status: 0
                    onClicked: {
                        if (page.state === "dayGraph")
                            return

                        page.state = "dayGraph"
                        // Change the energy graph is an operation that ideally
                        // should be put inside the state change, but in this way
                        // (because is a very slow operation) the user experience
                        // is better because the ui does not appears blocked.
                        graphLoader.setComponent(energyDayGraphComponent)
                    }
                }
                ButtonThreeStates {
                    id: monthButton
                    font.pixelSize: 14
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("month")
                    status: 1
                    onClicked: {
                        if (page.state === "")
                            return

                        page.state = ""
                        graphLoader.setComponent(energyMonthGraphComponent)
                    }
                }
                ButtonThreeStates {
                    id: yearButton
                    font.pixelSize: 14
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("year")
                    status: 0
                    onClicked: {
                        if (page.state === "yearGraph")
                            return

                        page.state = "yearGraph"
                        // Change the energy graph is an operation that ideally
                        // should be put inside the state change, but in this way
                        // (because is a very slow operation) the user experience
                        // is better because the ui does not appears blocked.
                        graphLoader.setComponent(energyYearGraphComponent)
                    }
                }
            }

            Item {
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: buttonRow.left
                    left: timeButtonRow.right
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter

                    ButtonImageThreeStates {
                        id: graphButton
                        defaultImageBg: "images/energy/btn_value.svg"
                        pressedImageBg: "images/energy/btn_value_P.svg"
                        selectedImageBg: "images/energy/btn_value_S.svg"
                        defaultImage: "images/energy/ico_graph.svg"
                        pressedImage: "images/energy/ico_graph_P.svg"
                        selectedImage: "images/energy/ico_graph_P.svg"
                        shadowImage: "images/energy/ombra_btn_value.svg"
                        status: 1
                        onClicked: {}
                    }
                    ButtonImageThreeStates {
                        id: tableButton
                        defaultImageBg: "images/energy/btn_value.svg"
                        pressedImageBg: "images/energy/btn_value_P.svg"
                        selectedImageBg: "images/energy/btn_value_S.svg"
                        defaultImage: "images/energy/ico_table.svg"
                        pressedImage: "images/energy/ico_table_P.svg"
                        selectedImage: "images/energy/ico_table_P.svg"
                        shadowImage: "images/energy/ombra_btn_value.svg"
                        status: 0
                        enabled: false
                        onClicked: {}
                    }
                }
            }

            Row {
                id: buttonRow
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: divisorLine.right
                }

                ButtonThreeStates {
                    id: moneyButton
                    font.pixelSize: 14
                    defaultImage: "images/energy/btn_value.svg"
                    pressedImage: "images/energy/btn_value_P.svg"
                    selectedImage: "images/energy/btn_value_S.svg"
                    shadowImage: "images/energy/ombra_btn_value.svg"
                    text: qsTr("€")
                    status: privateProps.showCurrency === true ? 1 : 0
                    onClicked: privateProps.showCurrency = true
                    enabled: energyData.rate !== null
                }
                ButtonThreeStates {
                    id: consumptionButton
                    font.pixelSize: 14
                    defaultImage: "images/energy/btn_value.svg"
                    pressedImage: "images/energy/btn_value_P.svg"
                    selectedImage: "images/energy/btn_value_S.svg"
                    shadowImage: "images/energy/ombra_btn_value.svg"
                    text: qsTr("units")
                    status: privateProps.showCurrency === false ? 1 : 0
                    onClicked: privateProps.showCurrency = false
                }
            }

            SvgImage {
                id: divisorLine
                source: "images/energy/linea_grafico.svg"
                anchors {
                    top: buttonRow.bottom
                    topMargin: parent.height / 100 * 3
                    horizontalCenter: parent.horizontalCenter
                }
            }


            AnimatedLoader {
                id: graphLoader
                anchors {
                    top: divisorLine.bottom
                    left: divisorLine.left
                }

                duration: 200
                Component.onCompleted: setComponent(energyMonthGraphComponent)
            }

            Component {
                id: energyMonthGraphComponent
                EnergyMonthGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.monthDate
                    energyData: page.energyData
                }
            }

            Component {
                id: energyYearGraphComponent
                EnergyYearGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.yearDate
                    energyData: page.energyData
                }
            }

            Component {
                id: energyDayGraphComponent
                EnergyDayGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.dayDate
                    energyData: page.energyData
                }
            }
        }


        SvgImage {
            source: "images/energy/bg_grafico_consumption.svg"

            EnergyDateSelector {
                id: dateSelector
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    horizontalCenter: parent.horizontalCenter
                }
            }

            UbuntuLightText {
                text: qsTr("instant consumption")
                color: "white"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                anchors {
                    bottom: instantConsumption.top
                    bottomMargin: 5
                    left: instantConsumption.left
                    right: instantConsumption.right
                }
                horizontalAlignment: Text.AlignHCenter
            }

            SvgImage {
                id: instantConsumption
                source: "images/energy/bg_instant_consumption.svg"
                anchors {
                    top: dateSelector.bottom
                    topMargin: parent.height / 100 * 24
                    horizontalCenter: parent.horizontalCenter
                }
                UbuntuLightText {
                    property variant currentItem: energyData.getValue(EnergyData.CurrentValue, new Date(), // the Date does not matter
                                                                      privateProps.showCurrency ? EnergyData.Currency :
                                                                                                  EnergyData.Consumption)

                    anchors.centerIn: parent
                    text: currentItem.isValid ? currentItem.value.toFixed(currentItem.decimals) + " " + currentItem.measureUnit : ""
                    color: "grey"
                    font.pixelSize: 18
                }
            }

            UbuntuLightText {
                id: cumulativeConsumptionLabel
                text: qsTr("month cumulative consumption")
                color: "white"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                anchors {
                    bottom: cumulativeConsumptionItem.top
                    bottomMargin: 5
                    left: cumulativeConsumptionItem.left
                    right: cumulativeConsumptionItem.right
                }
                horizontalAlignment: Text.AlignHCenter
            }

            SvgImage {
                id: cumulativeConsumptionItem
                property int valueType: EnergyData.CumulativeMonthValue
                property date referredDate: dateSelector.monthDate

                property variant consumptionItem: energyData.getValue(valueType, referredDate,
                                                                      privateProps.showCurrency ? EnergyData.Currency :
                                                                                                  EnergyData.Consumption)

                source: "images/energy/livello_cumulative_consumption.svg"
                anchors {
                    top: instantConsumption.bottom
                    topMargin: parent.height / 100 * 25
                    horizontalCenter: parent.horizontalCenter
                }

                states: [
                    State {
                        name: "year"
                        PropertyChanges {
                            target: cumulativeConsumptionItem
                            valueType: EnergyData.CumulativeYearValue
                            referredDate: dateSelector.yearDate
                        }
                    },
                    State {
                        name: "day"
                        PropertyChanges {
                            target: cumulativeConsumptionItem
                            valueType: EnergyData.CumulativeDayValue
                            referredDate: dateSelector.dayDate
                        }
                    }
                ]

                UbuntuLightText {
                    anchors.centerIn: parent
                    text: parent.consumptionItem.isValid ? parent.consumptionItem.value.toFixed(parent.consumptionItem.decimals) + " " + parent.consumptionItem.measureUnit : ""
                    color: "grey"
                    font.pixelSize: 18
                }
            }
            SvgImage {
                source: "images/energy/ombra_livello_cumulative_consumption.svg"
                anchors.top: cumulativeConsumptionItem.bottom
                anchors.left: cumulativeConsumptionItem.left
                anchors.right: cumulativeConsumptionItem.right
            }
        }
    }


    EnergyManagementNames {
        id: translations
    }

    states: [
        State {
            name: "yearGraph"
            PropertyChanges { target: yearButton; status: 1 }
            PropertyChanges { target: monthButton; status: 0 }
            PropertyChanges { target: dayButton; status: 0 }
            PropertyChanges { target: dateSelector; state: "year" }
            PropertyChanges { target: cumulativeConsumptionItem; state: "year" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("year cumulative consumption") }

        },
        State {
            name: "dayGraph"
            PropertyChanges { target: yearButton; status: 0 }
            PropertyChanges { target: monthButton; status: 0 }
            PropertyChanges { target: dayButton; status: 1 }
            PropertyChanges { target: dateSelector; state: "day" }
            PropertyChanges { target: cumulativeConsumptionItem; state: "day" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("day cumulative consumption") }
        }
    ]
}
