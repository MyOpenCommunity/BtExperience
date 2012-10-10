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
        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeYearGraph, graphDate,
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

    height: 380 // required to make the separator line works

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
                        unitMeasure: energyData.cumulativeUnit
                    }
                }
            }
        }
    }
}



