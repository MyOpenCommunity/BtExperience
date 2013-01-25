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

    // this function is used externally when clicking on confirm for threshold
    // and we need to open the day graph
    function setComponentOnGraphLoader() {
        if (page.state === "year") {
            // Change the energy graph/table is an operation that ideally
            // should be put inside the state change, but in this way
            // (because is a very slow operation) the user experience
            // is better because the ui does not appears blocked.
            graphLoader.setComponent(privateProps.showTable ? energyYearTableComponent : energyYearGraphComponent)
            dateSelector.selectedDate = new Date()
        }
        else if (page.state === "day") {
            // Change the energy graph is an operation that ideally
            // should be put inside the state change, but in this way
            // (because is a very slow operation) the user experience
            // is better because the ui does not appears blocked.
            graphLoader.setComponent(privateProps.showTable ? energyDayTableComponent : energyDayGraphComponent)
            dateSelector.selectedDate = new Date()
        }
        else {
            graphLoader.setComponent(privateProps.showTable ? energyMonthTableComponent : energyMonthGraphComponent)
            dateSelector.selectedDate = new Date()
        }
    }

    showSystemsButton: true
    text: qsTr("energy consumption")
    source: "images/background/energy.jpg"

    EnergyFunctions {
        id: energyFunctions
    }

    QtObject {
        id: privateProps
        property bool showCurrency: false
        property bool showTable: false
    }

    SvgImage {
        id: header
        source: "images/energy/bg_titolo.svg"
        anchors {
            top: navigationBar.top
            left: parent.left
            leftMargin: 130
        }

        Image {
            source: "images/energy/" + energyFunctions.getIcon(energyData.energyType, true)

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
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    left: divisorLine.left
                }

                ButtonThreeStates {
                    id: dayButton
                    font.pixelSize: 14
                    defaultImage: "images/common/btn_84x35.svg"
                    pressedImage: "images/common/btn_84x35_P.svg"
                    selectedImage: "images/common/btn_84x35_S.svg"
                    shadowImage: "images/common/btn_shadow_84x35.svg"
                    text: qsTr("day")
                    onClicked: {
                        if (page.state === "day")
                            return

                        page.state = "day"
                        setComponentOnGraphLoader()
                    }
                }

                ButtonThreeStates {
                    id: monthButton
                    font.pixelSize: 14
                    defaultImage: "images/common/btn_84x35.svg"
                    pressedImage: "images/common/btn_84x35_P.svg"
                    selectedImage: "images/common/btn_84x35_S.svg"
                    shadowImage: "images/common/btn_shadow_84x35.svg"
                    text: qsTr("month")
                    status: 1
                    onClicked: {
                        if (page.state === "")
                            return

                        page.state = ""
                        setComponentOnGraphLoader()
                    }
                }
                ButtonThreeStates {
                    id: yearButton
                    font.pixelSize: 14
                    defaultImage: "images/common/btn_84x35.svg"
                    pressedImage: "images/common/btn_84x35_P.svg"
                    selectedImage: "images/common/btn_84x35_S.svg"
                    shadowImage: "images/common/btn_shadow_84x35.svg"
                    text: qsTr("year")
                    onClicked: {
                        if (page.state === "year")
                            return

                        page.state = "year"
                        setComponentOnGraphLoader()
                    }
                }
            }

            Item {
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: buttonRowLoader.left
                    left: timeButtonRow.right
                }

                Row {
                    id: tableGraphButtons
                    anchors.horizontalCenter: parent.horizontalCenter

                    ButtonImageThreeStates {
                        id: graphButton
                        defaultImageBg: "images/common/btn_66x35.svg"
                        pressedImageBg: "images/common/btn_66x35_P.svg"
                        selectedImageBg: "images/common/btn_66x35_S.svg"
                        shadowImage: "images/common/btn_shadow_66x35.svg"
                        defaultImage: "images/energy/ico_graph.svg"
                        pressedImage: "images/energy/ico_graph_P.svg"
                        selectedImage: "images/energy/ico_graph_P.svg"
                        status: privateProps.showTable === false ? 1 : 0
                        onClicked: {
                            if (privateProps.showTable) {
                                privateProps.showTable = false
                                if (page.state == "")
                                    graphLoader.setComponent(energyMonthGraphComponent)
                                else if (page.state == "day")
                                    graphLoader.setComponent(energyDayGraphComponent)
                                else // year
                                    graphLoader.setComponent(energyYearGraphComponent)
                            }
                        }
                    }
                    ButtonImageThreeStates {
                        id: tableButton
                        defaultImageBg: "images/common/btn_66x35.svg"
                        pressedImageBg: "images/common/btn_66x35_P.svg"
                        selectedImageBg: "images/common/btn_66x35_S.svg"
                        shadowImage: "images/common/btn_shadow_66x35.svg"
                        defaultImage: "images/energy/ico_table.svg"
                        pressedImage: "images/energy/ico_table_P.svg"
                        selectedImage: "images/energy/ico_table_P.svg"
                        status: privateProps.showTable === true ? 1 : 0
                        onClicked: {
                            if (!privateProps.showTable) {
                                privateProps.showTable = true
                                if (page.state == "")
                                    graphLoader.setComponent(energyMonthTableComponent)
                                else if (page.state == "day")
                                    graphLoader.setComponent(energyDayTableComponent)
                                else // year
                                    graphLoader.setComponent(energyYearTableComponent)
                            }
                        }
                    }
                }
            }

            Loader {
                id: buttonRowLoader
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: divisorLine.right
                }
                sourceComponent: energyData.rate !== null ? buttonRowComponent : undefined
            }

            Component {
                id: buttonRowComponent

                Row {
                    ButtonThreeStates {
                        id: moneyButton
                        font.pixelSize: 14
                        defaultImage: "images/common/btn_66x35.svg"
                        pressedImage: "images/common/btn_66x35_P.svg"
                        selectedImage: "images/common/btn_66x35_S.svg"
                        shadowImage: "images/common/btn_shadow_66x35.svg"
                        text: energyData.rate.currencySymbol
                        status: privateProps.showCurrency === true ? 1 : 0
                        onClicked: privateProps.showCurrency = true
                        enabled: energyData.rate !== null
                    }
                    ButtonThreeStates {
                        id: consumptionButton
                        font.pixelSize: 14
                        defaultImage: "images/common/btn_66x35.svg"
                        pressedImage: "images/common/btn_66x35_P.svg"
                        selectedImage: "images/common/btn_66x35_S.svg"
                        shadowImage: "images/common/btn_shadow_66x35.svg"
                        text: energyData.cumulativeUnit
                        status: privateProps.showCurrency === false ? 1 : 0
                        onClicked: privateProps.showCurrency = false
                    }
                }
            }

            SvgImage {
                id: divisorLine
                source: "images/energy/linea_grafico.svg"
                anchors {
                    top: timeButtonRow.bottom
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
                Component.onCompleted: if (page.state === "") setComponent(energyMonthGraphComponent)
            }

            Component {
                id: energyMonthGraphComponent
                EnergyMonthGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                    onDayClicked: {
                        page.state = "day"
                        graphLoader.setComponent(energyDayGraphComponent)

                        // This trick are required to make the property signal
                        // works when we change the data.
                        var date = dateSelector.selectedDate
                        date.setFullYear(year)
                        date.setMonth(month)
                        date.setDate(day)
                        dateSelector.selectedDate = date
                    }
                }
            }

            Component {
                id: energyMonthTableComponent
                EnergyMonthTable {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                }
            }

            Component {
                id: energyYearGraphComponent
                EnergyYearGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                    onMonthClicked: {
                        page.state = ""
                        graphLoader.setComponent(energyMonthGraphComponent)

                        // This trick are required to make the property signal
                        // works when we change the data.
                        var date = dateSelector.selectedDate
                        date.setFullYear(year)
                        date.setMonth(month)
                        dateSelector.selectedDate = date
                    }
                }
            }

            Component {
                id: energyYearTableComponent
                EnergyYearTable {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                }
            }

            Component {
                id: energyDayGraphComponent
                EnergyDayGraph {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                }
            }

            Component {
                id: energyDayTableComponent
                EnergyDayTable {
                    showCurrency: privateProps.showCurrency
                    graphDate: dateSelector.selectedDate
                    energyData: page.energyData
                }
            }
        }


        SvgImage {
            source: "images/energy/bg_grafico_consumption.svg"

            EnergyDateSelector {
                id: dateSelector
                energyData: page.energyData
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
                EnergyItemObject {
                    id: currentValue
                    energyData: page.energyData
                    valueType: EnergyData.CurrentValue
                    date: new Date()
                    measureType: privateProps.showCurrency ? EnergyData.Currency :
                                                             EnergyData.Consumption
                }
                UbuntuLightText {
                    property variant currentItem: currentValue.item

                    anchors.centerIn: parent
                    text: energyFunctions.formatValue(currentItem)
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
                property date referredDate: dateSelector.selectedDate

                EnergyItemObject {
                    id: consumptionValue
                    energyData: page.energyData
                    valueType: cumulativeConsumptionItem.valueType
                    date: cumulativeConsumptionItem.referredDate
                    measureType: privateProps.showCurrency ? EnergyData.Currency :
                                                             EnergyData.Consumption
                }

                property variant consumptionItem: consumptionValue.item

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
                            valueType: energyData.advanced ? EnergyData.CumulativeYearValue : EnergyData.CumulativeLastYearValue
                        }
                    },
                    State {
                        name: "day"
                        PropertyChanges {
                            target: cumulativeConsumptionItem
                            valueType: EnergyData.CumulativeDayValue
                        }
                    }
                ]

                UbuntuLightText {
                    anchors.centerIn: parent
                    text: energyFunctions.formatValue(cumulativeConsumptionItem.consumptionItem)
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
            name: "year"
            PropertyChanges { target: yearButton; status: 1 }
            PropertyChanges { target: monthButton; status: 0 }
            PropertyChanges { target: dayButton; status: 0 }
            PropertyChanges { target: dateSelector; state: energyData.advanced ? "year" : "lastyear" }
            PropertyChanges { target: cumulativeConsumptionItem; state: "year" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("year cumulative consumption") }

        },
        State {
            name: "day"
            PropertyChanges { target: yearButton; status: 0 }
            PropertyChanges { target: monthButton; status: 0 }
            PropertyChanges { target: dayButton; status: 1 }
            PropertyChanges { target: dateSelector; state: "day" }
            PropertyChanges { target: cumulativeConsumptionItem; state: "day" }
            PropertyChanges { target: cumulativeConsumptionLabel; text: qsTr("day cumulative consumption") }
        }
    ]
}
