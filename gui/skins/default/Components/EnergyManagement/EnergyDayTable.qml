import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

Item {
    property bool showCurrency
    property date graphDate
    property variant energyData

    QtObject {
        id: privateProps
        property int horizontalSpacing: 15
        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeDayGraph, graphDate,
                                                         showCurrency ? EnergyData.Currency : EnergyData.Consumption)

        function isRowValid(i) {
            return privateProps.modelGraph.isValid && privateProps.modelGraph.graph[i] !== undefined
        }

        function getRowIndex(i) {
            if (isRowValid(i))
                return privateProps.modelGraph.graph[i].index
            return ""
        }

        function getRowValue(i) {
            if (isRowValid(i))
                return privateProps.modelGraph.graph[i].value.toFixed(energyData.decimals)

            return ""
        }
    }

    height: 280 // required to make the separator line works

    Column {
        id: firstColumn
        anchors {
            top: parent.top
            topMargin: 20
            bottom: parent.bottom
            left: parent.left
        }

        Repeater {
            model: 8 + 1
            delegate: Loader {
                property int offset: 0
                sourceComponent: model.index === 0 ? tableHeaderComponent : tableRowComponent

                Component {
                    id: tableRowComponent
                    EnergyTableRow {
                        index: privateProps.getRowIndex(model.index - 1 + offset)
                        value: privateProps.getRowValue(model.index - 1 + offset)
                    }
                }

                Component {
                    id: tableHeaderComponent
                    EnergyTableHeader {
                        label: qsTr("hour")
                        unitMeasure: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
                    }
                }
            }
        }
    }

    SvgImage {
        id: firstSeparator
        anchors {
            left: firstColumn.right
            leftMargin: privateProps.horizontalSpacing
            top: firstColumn.top
            bottom: parent.bottom
            bottomMargin: 30
        }
        source: "../../images/energy/separator_table-dmy_small.svg"
    }

    Column {
        id: secondColumn
        anchors {
            top: firstColumn.top
            bottom: firstColumn.bottom
            left: firstSeparator.right
            leftMargin: privateProps.horizontalSpacing
        }

        Repeater {
            model: 8 + 1
            delegate: Loader {
                property int offset: 8
                sourceComponent: model.index === 0 ? tableHeaderComponent2 : tableRowComponent2

                Component {
                    id: tableRowComponent2
                    EnergyTableRow {
                        index: privateProps.getRowIndex(model.index - 1 + offset)
                        value: privateProps.getRowValue(model.index - 1 + offset)
                    }
                }

                Component {
                    id: tableHeaderComponent2
                    EnergyTableHeader {
                        label: qsTr("hour")
                        unitMeasure: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
                    }
                }
            }
        }
    }

    SvgImage {
        id: secondSeparator
        anchors {
            left: secondColumn.right
            leftMargin: privateProps.horizontalSpacing
            top: firstSeparator.top
            bottom: firstSeparator.bottom
        }
        source: "../../images/energy/separator_table-dmy_small.svg"
    }


    Column {
        id: thirdColumn
        anchors {
            top: firstColumn.top
            bottom: firstColumn.bottom
            left: secondSeparator.right
            leftMargin: privateProps.horizontalSpacing
        }

        Repeater {
            model: 8 + 1
            delegate: Loader {
                property int offset: 16

                sourceComponent: model.index === 0 ? tableHeaderComponent3 : tableRowComponent3

                Component {
                    id: tableRowComponent3
                    EnergyTableRow {
                        index: privateProps.getRowIndex(model.index - 1 + offset)
                        value: privateProps.getRowValue(model.index - 1 + offset)
                    }
                }

                Component {
                    id: tableHeaderComponent3
                    EnergyTableHeader {
                        label: qsTr("hour")
                        unitMeasure: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
                    }
                }
            }
        }
    }
}


