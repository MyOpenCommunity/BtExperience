import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Item {
    id: itemGraph
    property variant modelGraph: undefined

    QtObject {
        id: privateProps
        property real maxValue: itemGraph.modelGraph.maxValue * 1.1
        property int columnSpacing: 17

    }

    SvgImage {
        id: columnPrototype
        visible: false
        source: "../../images/energy/colonna_year.svg"
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
                    source: "../../images/energy/ombra_colonna_year.svg"
                    anchors.top: columnGraphBg.bottom
                }

                SvgImage {
                    source: "../../images/energy/colonna_year_verde.svg"
                    anchors {
                        left: columnGraphBg.left
                        right: columnGraphBg.right
                        bottom: columnGraphBg.bottom
                    }
                    z: 1

                    height: {
                        if (!modelGraph.isValid)
                            return 0
                        else {
                            return model.modelData.value / privateProps.maxValue * columnGraphBg.height
                        }
                    }
                }
            }
            model: modelGraph.graph
        }
    }
}
