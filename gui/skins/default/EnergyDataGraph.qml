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
            source: "images/energy/ico_electricity_bianca.svg"
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
                    leftMargin: divisorLine.width / 100 * 17
                }

                UbuntuLightText {
                    text: qsTr("time")
                    color: "white"
                    anchors.verticalCenter: dayButton.verticalCenter
                    font.pixelSize: 14
                }
                Item {
                    width: 15
                    height: dayButton.height
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
                    enabled: true // TODO: what are the logics to do that?
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
                    enabled: true // TODO: what are the logics to do that?
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
                    enabled: true // TODO: what are the logics to do that?
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

            Row {
                id: buttonRow
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: divisorLine.right
                }

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
                    text: currentItem.value.toFixed(2) + " " + currentItem.measureUnit
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
                    bottom: cumulativeConsumptionLoader.top
                    bottomMargin: 5
                    left: cumulativeConsumptionLoader.left
                    right: cumulativeConsumptionLoader.right
                }
                horizontalAlignment: Text.AlignHCenter
            }

            Loader {
                id: cumulativeConsumptionLoader
                anchors {
                    top: instantConsumption.bottom
                    topMargin: parent.height / 100 * 25
                    horizontalCenter: parent.horizontalCenter
                }
                sourceComponent: monthCumulativeConsumptionComponent
                property int valueType: EnergyData.CumulativeMonthValue
                property date referredDate: dateSelector.monthDate

                property variant consumptionItem: energyData.getValue(valueType,
                                                                      referredDate, EnergyData.Consumption)

                states: [
                    State {
                        name: "year"
                        PropertyChanges {
                            target: cumulativeConsumptionLoader
                            valueType: EnergyData.CumulativeYearValue
                            referredDate: dateSelector.yearDate
                            sourceComponent: cumulativeConsumptionComponent
                        }
                    },
                    State {
                        name: "day"
                        PropertyChanges {
                            target: cumulativeConsumptionLoader
                            valueType: EnergyData.CumulativeDayValue
                            referredDate: dateSelector.dayDate
                            sourceComponent: cumulativeConsumptionComponent
                        }
                    }
                ]
            }

            Component {
                id: monthCumulativeConsumptionComponent
                SvgImage {
                    source: "images/energy/livello_cumulative_consumption.svg"

                    EnergyConsumptionLogic {
                        id: logic
                        monthConsumptionItem: cumulativeConsumptionLoader.consumptionItem
                    }

                    SvgImage {
                        source: "images/energy/livello_cumulative_consumption_" + (logic.consumptionExceedGoal() ? "rosso" : "verde") + ".svg"
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: logic.getConsumptionSize(parent.width)
                    }

                    SvgImage {
                        source: "images/energy/linea_livello_cumulative_consumption.svg"
                        visible: logic.hasGoal()
                        anchors.left: parent.left
                        anchors.leftMargin: logic.goalSize(parent.width)
                        height: parent.height
                    }
                }
            }

            Component {
                id: cumulativeConsumptionComponent

                SvgImage {
                    source: "images/energy/livello_cumulative_consumption.svg"
                    SvgImage {
                        source: "images/energy/livello_cumulative_consumption_verde.svg"
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: consumptionItem.isValid ? parent.width / 100 * 80 : 0 // TODO: calculate the bar length (in some way) from the value property.
                    }
                }
            }

            SvgImage {
                source: "images/energy/ombra_livello_cumulative_consumption.svg"
                anchors.top: cumulativeConsumptionLoader.bottom
                anchors.left: cumulativeConsumptionLoader.left
                anchors.right: cumulativeConsumptionLoader.right
            }

            UbuntuLightText {
                text: cumulativeConsumptionValue.energyItem.measureUnit
                color: "white"
                font.pixelSize: 14
                anchors {
                    top: cumulativeConsumptionLoader.bottom
                    topMargin: 5
                    left: cumulativeConsumptionLoader.left
                }
            }

            UbuntuLightText {
                id: cumulativeConsumptionValue
                // We want not to use the consumptionItem inside the cumulativeConsumptionLoader
                // component because it never use the currency (because we don't know at this moment
                // if the goal can be corverted).
                property variant energyItem: energyData.getValue(cumulativeConsumptionLoader.valueType,
                                                                 cumulativeConsumptionLoader.referredDate,
                    privateProps.showCurrency ? EnergyData.Currency : EnergyData.Consumption)

                text: energyItem.isValid ? energyItem.value.toFixed(2) : 0
                font.pixelSize: 14
                color: "white"
                anchors {
                    top: cumulativeConsumptionLoader.bottom
                    topMargin: 5
                    right: cumulativeConsumptionLoader.right
                }
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
            PropertyChanges { target: cumulativeConsumptionLoader; state: "year" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("year cumulative consumption") }

        },
        State {
            name: "dayGraph"
            PropertyChanges { target: yearButton; status: 0 }
            PropertyChanges { target: monthButton; status: 0 }
            PropertyChanges { target: dayButton; status: 1 }
            PropertyChanges { target: dateSelector; state: "day" }
            PropertyChanges { target: cumulativeConsumptionLoader; state: "day" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("day cumulative consumption") }
        }
    ]
}
