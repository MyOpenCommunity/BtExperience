import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

Item {
    property bool showCurrency
    property date graphDate
    property variant energyData

    QtObject {
        id: privateProps
        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeMonthGraph, graphDate,
                                                         showCurrency ? EnergyData.Currency : EnergyData.Consumption)
        property real maxValue: modelGraph.maxValue * 1.1
        property int columnSpacing: 6
    }

    SvgImage {
        id: columnPrototype
        visible: false
        source: "../../images/energy/colonna_month.svg"
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
        font.pointSize: 12
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
               font.pointSize: 12
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
        spacing: privateProps.columnSpacing
        Repeater {
            Item {
                width: columnGraphBg.width
                height: columnGraphBg.height

                SvgImage {
                    id: columnGraphBg
                    source: columnPrototype.source
                }

                SvgImage {
                    source: "../../images/energy/ombra_colonna_month.svg"
                    anchors.top: columnGraphBg.bottom
                }

                SvgImage {
                    source: "../../images/energy/colonna_month_verde.svg"
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

        ListModel {
            id: daysModel

            ListElement {
                value: 1
            }
            ListElement {
                value: 5
            }
            ListElement {
                value: 10
            }
            ListElement {
                value: 15
            }
            ListElement {
                value: 20
            }
            ListElement {
                value: 25
            }
            ListElement {
                value: 30
            }
        }

        Repeater {
            model: daysModel
            UbuntuLightText {
                visible: value <= privateProps.modelGraph.graph.length
                text: model.value
                width: columnPrototype.width
                color: "white"
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                x: (value - 1) * (columnPrototype.width + privateProps.columnSpacing)
            }
        }
    }

    UbuntuLightText {
        id: periodLabel
        anchors {
            top: periodAxis.bottom
            topMargin: 10
            left: periodAxis.left
        }
        text: qsTr("day")
        color: "white"
        font.pointSize: 12
    }

}



