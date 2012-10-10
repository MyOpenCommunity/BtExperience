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

        Item {
            anchors.fill: parent

            SvgImage {
                id: firstSeparator
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 40
                }
                source: "../../images/energy/separator_table-dmy_small.svg"
            }

            Column {
                id: secondColumn
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: firstSeparator.right
                    leftMargin: privateProps.horizontalSpacing
                }

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
                                label: qsTr("objective")
                                unitMeasure: qsTr("delta")
                            }
                        }
                    }
                }
            }
        }
    }

}



