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
        Stack.showPreviousPage(1)
    }

    showSystemsButton: true
    text: qsTr("energy consumption")
    source: "images/bg2.jpg"

    QtObject {
        id: privateProps
        property bool showCurrency: false
        property int graphType: EnergyData.CumulativeMonthGraph
        property variant modelGraph: energyData.getGraph(graphType, dateSelector.date,
                                                         showCurrency ? EnergyData.Currency: EnergyData.Consumption)
        property variant monthConsumption: energyData.getValue(EnergyData.CumulativeMonthValue,
            dateSelector.date, EnergyData.Consumption)
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

            font.pixelSize: 24
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
                    text: "time"
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
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("day")
                    status: 0
                    enabled: dateSelector.isEnergyDayValid(dateSelector.date)
                    Rectangle {
                        z: 1
                        anchors.fill: parent
                        color: "silver"
                        opacity: 0.6
                        visible: parent.enabled === false
                    }
                    onClicked: {}
                }
                ButtonThreeStates {
                    id: monthButton
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("month")
                    status: 1
                    enabled: dateSelector.isEnergyMonthValid(dateSelector.date)
                    Rectangle {
                        z: 1
                        anchors.fill: parent
                        color: "silver"
                        opacity: 0.6
                        visible: parent.enabled === false
                    }
                    onClicked: {
                        page.state = ""
                        pageContent.sourceComponent = energyMonthGraphComponent
                    }
                }
                ButtonThreeStates {
                    id: yearButton
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("year")
                    status: 0
                    enabled: dateSelector.isEnergyYearValid(dateSelector.date)
                    Rectangle {
                        z: 1
                        anchors.fill: parent
                        color: "silver"
                        opacity: 0.6
                        visible: parent.enabled === false
                    }
                    onClicked: {
                        page.state = "yearGraph"
                        // Change the energy graph is an operation that ideally
                        // should be put inside the state change, but in this way
                        // (because is a very slow operation) the user experience
                        // is better because the ui does not appears blocked.
                        pageContent.sourceComponent = energyYearGraphComponent
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
                    text: "value"
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
                    defaultImage: "images/energy/btn_value.svg"
                    pressedImage: "images/energy/btn_value_P.svg"
                    selectedImage: "images/energy/btn_value_S.svg"
                    shadowImage: "images/energy/ombra_btn_value.svg"
                    text: qsTr("€")
                    status: privateProps.showCurrency === true ? 1 : 0
                    onClicked: privateProps.showCurrency = true
                }
                ButtonThreeStates {
                    id: consumptionButton
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


            Loader {
                id: pageContent
                anchors {
                    top: divisorLine.bottom
                    topMargin: parent.height * 0.1
                    left: divisorLine.left
                }

                sourceComponent: energyMonthGraphComponent
            }

            Component {
                id: energyMonthGraphComponent
                EnergyMonthGraph {
                    modelGraph: privateProps.modelGraph
                }
            }

            Component {
                id: energyYearGraphComponent
                EnergyYearGraph {
                    modelGraph: privateProps.modelGraph
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
                    anchors.centerIn: parent
                    text: "45 w/h"
                    color: "grey"
                    font.pixelSize: 16
                }
            }


            UbuntuLightText {
                text: qsTr("month cumulative consumption")
                color: "white"
                wrapMode: Text.WordWrap
                anchors {
                    bottom: cumulativeConsumption.top
                    bottomMargin: 5
                    left: cumulativeConsumption.left
                    right: cumulativeConsumption.right
                }
                horizontalAlignment: Text.AlignHCenter
            }

            EnergyConsumptionLogic {
                id: logic
                monthConsumptionItem: privateProps.monthConsumption
            }

            SvgImage {
                id: cumulativeConsumption
                source: "images/energy/livello_cumulative_consumption.svg"
                anchors {
                    top: instantConsumption.bottom
                    topMargin: parent.height / 100 * 25
                    horizontalCenter: parent.horizontalCenter
                }

                SvgImage {
                    source:  "images/energy/livello_cumulative_consumption_" + (logic.consumptionExceedGoal() ? "rosso" : "verde") + ".svg"
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

            SvgImage {
                source: "images/energy/ombra_livello_cumulative_consumption.svg"
                anchors.top: cumulativeConsumption.bottom
                anchors.left: cumulativeConsumption.left
                anchors.right: cumulativeConsumption.right
            }

            UbuntuLightText {
                text: cumulativeConsumptionLabel.monthItem.measureUnit
                color: "white"
                anchors {
                    top: cumulativeConsumption.bottom
                    topMargin: 5
                    left: cumulativeConsumption.left
                }
            }

            UbuntuLightText {
                id: cumulativeConsumptionLabel
                property variant monthItem: energyData.getValue(EnergyData.CumulativeMonthValue, dateSelector.date,
                    privateProps.showCurrency ? EnergyData.Currency : EnergyData.Consumption)

                text: monthItem.value.toFixed(2)
                color: "white"
                anchors {
                    top: cumulativeConsumption.bottom
                    topMargin: 5
                    right: cumulativeConsumption.right
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
            PropertyChanges { target: privateProps; graphType: EnergyData.CumulativeYearGraph }
            PropertyChanges { target: dateSelector; state: "year" }
        }
    ]
}
