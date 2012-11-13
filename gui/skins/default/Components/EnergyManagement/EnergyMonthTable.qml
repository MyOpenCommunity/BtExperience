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
        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeMonthGraph, graphDate,
                                                         showCurrency ? EnergyData.Currency : EnergyData.Consumption)

        function isRowValid(i) {
            return privateProps.modelGraph.isValid && privateProps.modelGraph.graph[i] !== undefined
        }

        function getRowIndex(i) {
            if (isRowValid(i))
                return privateProps.modelGraph.graph[i].index + 1
            return ""
        }

        function getRowValue(i) {
            if (isRowValid(i))
                return privateProps.modelGraph.graph[i].value.toFixed(energyData.decimals)

            return ""
        }
    }

    height: 350 // required to make the separator line works

    Column {
        id: firstColumn
        anchors {
            top: parent.top
            topMargin: 20
            bottom: parent.bottom
            left: parent.left
        }

        Repeater {
            model: 10 + 1
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
                        label: qsTr("day")
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
            model: 10 + 1
            delegate: Loader {
                property int offset: 10
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
                        label: qsTr("day")
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
            model: 11 + 1
            delegate: Loader {
                property int offset: 20

                sourceComponent: {
                    if (model.index === 0)
                        return tableHeaderComponent3
                    else if (model.index - 1 + offset < privateProps.modelGraph.graph.length)
                        return tableRowComponent3

                    return undefined
                }

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
                        label: qsTr("day")
                        unitMeasure: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
                    }
                }
            }
        }
    }
}

