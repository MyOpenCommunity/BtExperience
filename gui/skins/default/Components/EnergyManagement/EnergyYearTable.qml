import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

Item {
    id: component
    property bool showCurrency
    property date graphDate
    property variant energyData

    EnergyGraphObject {
        id: modelGraphValue
        energyData: component.energyData
        graphType: EnergyData.CumulativeYearGraph
        date: component.graphDate
        measureType: component.showCurrency ? EnergyData.Currency : EnergyData.Consumption
    }

    QtObject {
        id: privateProps
        property int horizontalSpacing: 5
        property variant modelGraph: modelGraphValue.graph

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
                return privateProps.modelGraph.graph[i].value.toFixed(privateProps.modelGraph.decimals)

            return ""
        }
    }

    Column {
        id: firstColumn
        anchors {
            top: parent.top
            topMargin: 20
            bottom: parent.bottom
            left: parent.left
        }

        Repeater {
            model: 12 + 1
            delegate: Loader {
                sourceComponent: model.index === 0 ? tableHeaderComponent : tableRowComponent

                Component {
                    id: tableRowComponent
                    EnergyTableRow {
                        index: privateProps.getRowIndex(model.index - 1)
                        value: privateProps.getRowValue(model.index - 1)
                    }
                }

                Component {
                    id: tableHeaderComponent
                    EnergyTableHeader {
                        label: qsTr("month")
                        unitMeasure: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
                    }
                }
            }
        }
    }

    Loader {
        anchors {
            top: firstColumn.top
            bottom: parent.bottom
            left: firstColumn.right
            leftMargin: privateProps.horizontalSpacing
            right: parent.right
        }

        sourceComponent: {
            if (energyData.goalsEnabled) {
                for (var i = 0; i < energyData.goals.length; i += 1)
                    if (energyData.goals[i] > 0)
                        return goalColumnComponent
            }

            return undefined
        }
    }

    Component {
        id: goalColumnComponent

        Column {
            id: secondColumn
            anchors.fill: parent

            Repeater {
                model: 12 + 1
                delegate: Loader {
                    function calculateDelta() {
                        if (privateProps.isRowValid(model.index - 1))
                            return privateProps.modelGraph.graph[model.index - 1].value - energyData.goals[model.index - 1]

                        return 0
                    }

                    property real delta: calculateDelta()

                    sourceComponent: model.index === 0 ? tableHeaderComponent2 : tableRowComponent2

                    Component {
                        id: tableRowComponent2
                        EnergyTableRow {
                            index: privateProps.isRowValid(model.index - 1) ? energyData.goals[model.index - 1].toFixed(energyData.decimals) : ""
                            indexHorizontalAlignment: Text.AlignRight
                            value: {
                                if (privateProps.isRowValid(model.index - 1))
                                    return (delta > 0 ? "+" : "-") + " " + Math.abs(delta).toFixed(energyData.decimals)
                                return ""
                            }

                            valueColor: delta < 0 ? "#00ff00" : "#ff2b2b"
                        }
                    }

                    Component {
                        id: tableHeaderComponent2
                        EnergyTableHeader {
                            label: qsTr("Goal")
                            unitMeasure: qsTr("delta")
                        }
                    }
                }
            }
        }
    }
}



