import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

Item {
    id: itemGraph
    property bool showCurrency
    property date graphDate
    property variant energyData

    QtObject {
        id: privateProps

        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeYearGraph, graphDate,
                                                         showCurrency ? EnergyData.Currency : EnergyData.Consumption)

        property variant previousGraph: energyData.getGraph(EnergyData.CumulativeYearGraph, _previousYear(graphDate),
                                                            showCurrency ? EnergyData.Currency : EnergyData.Consumption)

        function _previousYear(d) {
            d.setFullYear(d.getFullYear() - 1)
            return d
        }

        function hasPreviousYear() {
            // TODO: what is the right way to do this check?
            if (itemGraph.graphDate.getFullYear() > 2010)
                return true
            return false
        }

        function calculateMaxValue() {
            var max_data =  Math.max(modelGraph.maxValue, previousGraph.maxValue)

            if (modelGraph.maxConsumptionGoal === undefined)
                return max_data * 1.1
            else {
                return Math.max(max_data, modelGraph.maxConsumptionGoal) * 1.1
            }
        }

        property real maxValue: calculateMaxValue()
        property int previousYearSpacing: 2
        property int columnSpacing: 17
    }

    SvgImage {
        id: columnPrototype
        visible: false
        source: "../../images/energy/colonna_year.svg"
    }


    SvgImage {
        id: previousYearPrototype
        visible: false
        source: "../../images/energy/colonna_previous_year.svg"
    }

    UbuntuLightText {
        id: valuesLabel
        anchors {
            bottom: valuesAxis.top
            bottomMargin: 15
            left: valuesAxis.left
        }
        text: qsTr("units")
        color: "white"
        font.pixelSize: 11
    }

    Item {
        id: valuesAxis
        property int numValues: 6
        anchors.top: graph.top
        anchors.bottom: graph.bottom
        anchors.left: parent.left
        width: 35

        function calculateValue(index) {
            if (index === numValues)
                return 0
            if (index === 0)
                return privateProps.maxValue

            // Because the last value is always 0, we have to use numValues - 1.
            return privateProps.maxValue / (numValues - 1) * (numValues -1 - index)
        }

        Repeater {
            UbuntuLightText {
               text: valuesAxis.calculateValue(index).toFixed(0)
               color: "white"
               font.pixelSize: 11
               anchors.left: parent.left
               // We remove the paintedHeight from the calculation because we want to draw
               // the last value on top of the graph colunm.
               y: index * ((columnPrototype.height - paintedHeight) / (valuesAxis.numValues - 1))
            }
            model: valuesAxis.numValues
        }
    }

    Row {
        id: graph
        anchors {
            top: parent.top
            left: valuesAxis.right
        }
        spacing: privateProps.columnSpacing - (privateProps.hasPreviousYear() ? previousYearPrototype.width + privateProps.previousYearSpacing : 0)
        Repeater {
            Item {
//                Component.onCompleted: { // Debug purpose only

//                    if (privateProps.hasPreviousYear() && privateProps.previousGraph.isValid)
//                        console.log("Current Value: " + model.modelData.value + " Previous Value:" + privateProps.previousGraph.getGraphBar(index).value +
//                                    " Goal: " + model.modelData.consumptionGoal)
//                    else
//                        console.log("Current Value: " + model.modelData.value + " Goal: " + model.modelData.consumptionGoal)
//                }

                width: columnGraphBg.width + (previusYearBar.visible ? previusYearBar.width + privateProps.previousYearSpacing : 0)
                height: columnGraphBg.height + columnShadow.height

                SvgImage {
                    id: columnGraphBg
                    source: columnPrototype.source
                }

                SvgImage {
                    id: columnShadow
                    source: "../../images/energy/ombra_colonna_year.svg"
                    anchors.top: columnGraphBg.bottom
                    anchors.left: columnGraphBg.left
                }

                SvgImage {
                    source: {
                        if (model.modelData.consumptionGoal !== undefined && model.modelData.value > model.modelData.consumptionGoal)
                            return "../../images/energy/colonna_year_rosso.svg"
                        return "../../images/energy/colonna_year_verde.svg"
                    }
                    anchors {
                        left: columnGraphBg.left
                        right: columnGraphBg.right
                        bottom: columnGraphBg.bottom
                    }
                    z: 1

                    height: {
                        if (!privateProps.modelGraph.isValid)
                            return 0
                        else {
                            return model.modelData.value / privateProps.maxValue * columnGraphBg.height
                        }
                    }
                }

                SvgImage {
                    visible: model.modelData.consumptionGoal !== undefined
                    source: "../../images/energy/linea_livello_colonna_year.svg"

                    z: 2
                    anchors {
                        left: columnGraphBg.left
                        top: columnGraphBg.top
                        topMargin: columnGraphBg.height - (model.modelData.consumptionGoal / privateProps.maxValue * columnGraphBg.height)
                    }

                }

                SvgImage {
                    id: previusYearBar
                    visible: privateProps.hasPreviousYear()
                    anchors {
                        left: columnGraphBg.right
                        leftMargin: privateProps.previousYearSpacing
                        bottom: columnGraphBg.bottom
                    }

                    height: {
                        if (privateProps.previousGraph.isValid)
                            return privateProps.previousGraph.getGraphBar(index).value / privateProps.maxValue * columnGraphBg.height
                        else
                            return 0
                    }

                    source: "../../images/energy/colonna_previous_year.svg"
                }

                SvgImage {
                    visible: privateProps.hasPreviousYear()
                    source: "../../images/energy/ombra_colonna_previous_year.svg"
                    anchors.top: previusYearBar.bottom
                    anchors.left: previusYearBar.left
                }
            }
            model: privateProps.modelGraph.graph
        }
    }


    Item {
        id: periodAxis
        height: childrenRect.height

        anchors {
            left: graph.left
            right: graph.right
            top: graph.bottom
            topMargin: 5
        }


        Repeater {
            model: privateProps.modelGraph.graph
            UbuntuLightText {
                text: model.modelData.label
                font.capitalization: Font.AllUppercase
                width: columnPrototype.width
                color: "white"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                x: index * (columnPrototype.width + privateProps.columnSpacing)
            }
        }
    }


}
