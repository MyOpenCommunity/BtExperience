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
            top: parent.top
            topMargin: 20
            left: valuesAxis.left
        }
        text: qsTr("units")
        color: "white"
        font.pixelSize: 12
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
               text: valuesAxis.calculateValue(index).toFixed(energyData.decimals)
               color: "white"
               font.pixelSize: 12
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
            top: valuesLabel.bottom
            topMargin: 15
            left: valuesAxis.right
        }
        spacing: privateProps.columnSpacing
        Repeater {
            Item {
                width: columnPrototype.width
                height: columnPrototype.height
                opacity: {
                    if (privateProps.modelGraph.isValid) {
                        return index < privateProps.modelGraph.graph.length ? 1: 0
                    }
                    return 1
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200; }
                }

                SvgImage {
                    source: "../../images/energy/ombra_colonna_month.svg"
                    anchors.top: parent.bottom
                }
            }
            // We draw the graph area with a fixed number of bars to optimize
            // the drawing operation, and we hide the exceeding bars (eg. the
            // 31st on 30-days months).
            // This way, when the underlying model changes the bars are not
            // redrawn anymore but simply hidden or shown.
            model: 31
        }
    }


    Row {
        id: greenBars
        anchors {
            top: graph.top
            bottom: graph.bottom
            left: graph.left
        }
        z: 1
        spacing: privateProps.columnSpacing

        Repeater {
            Item {
                height: columnPrototype.height
                width: columnPrototype.width
                SvgImage {
                    source: "../../images/energy/colonna_month_verde.svg"
                    anchors.bottom: parent.bottom
                    height: {
                        if (!privateProps.modelGraph.isValid)
                            return 0
                        else {
                            return model.modelData.value / privateProps.maxValue * columnPrototype.height
                        }
                    }
                }
            }

            model: privateProps.modelGraph.graph
        }
    }

    UbuntuLightText {
        // We use a "prototype" for the text box to have a fixed height so when
        // we change the model the periodLabel does not move anymore.
        id: graphLabelPrototype
        visible: false
        text: " "
        font.pixelSize: 12
    }

    Item {
        id: periodAxis
        height: graphLabelPrototype.height

        anchors {
            left: graph.left
            right: graph.right
            top: graph.bottom
            topMargin: 5
        }

        Repeater {
            model: privateProps.modelGraph.graph
            UbuntuLightText {
                visible: (index + 1) % 5 === 0 || index === 0
                text: model.modelData.label
                width: columnPrototype.width
                color: "white"
                font.pixelSize: graphLabelPrototype.font.pixelSize
                horizontalAlignment: Text.AlignHCenter
                x: index * (columnPrototype.width + privateProps.columnSpacing)
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
        font.pixelSize: 12
    }

}



