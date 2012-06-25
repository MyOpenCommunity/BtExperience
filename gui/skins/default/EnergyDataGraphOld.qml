import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.EnergyManagement 1.0

import "js/Stack.js" as Stack
import "js/RowColumnHelpers.js" as Helper


Page {
    id: page
    source: "images/scenari.jpg" // TODO mettere lo sfondo giusto

    property variant modelObject
    property int graphType
    property bool graphVisible: true
    property bool inCurrency: false
    property bool validGraph: modelObject.getGraph(page.graphType, timepoint, inCurrency ? EnergyData.Currency : EnergyData.Consumption).isValid
    property variant modelGraph: modelObject.getGraph(page.graphType, timepoint, inCurrency ? EnergyData.Currency : EnergyData.Consumption).graph
    property variant instantValue: modelObject.getValue(EnergyData.CurrentValue, timepoint, inCurrency ? EnergyData.Currency : EnergyData.Consumption)
    property variant cumulativeValue: modelObject.getValue(getValueType(graphType), timepoint, inCurrency ? EnergyData.Currency : EnergyData.Consumption).value
    property variant averageValue: cumulativeValue / 10 // TODO come si calcola?
    property date timepoint: new Date()

    function getValueType(g) {
        if (g === EnergyData.CumulativeDayGraph)
            return EnergyData.CumulativeDayValue
        else if (g === EnergyData.CumulativeMonthGraph)
            return EnergyData.CumulativeMonthValue
        else if (g === EnergyData.CumulativeYearGraph)
            return EnergyData.CumulativeYearValue
    }

    function systemsButtonClicked() {
        Stack.showPreviousPage(1)
    }

    text: translations.get("ENERGY_TYPE", page.modelObject.energyType)
    showSystemsButton: true

    Component.onCompleted: {
        // at page load completion we start all update requests
        modelObject.requestCurrentUpdateStart()
    }

    onVisibleChanged: {
        // when visibility changes, we modify all update requests
        // note that on destruction our Stack.js code makes the page
        // invisible, so we must not stop updates on destruction otherwise
        // we get errors while navigating back and forth a page
        if (visible) {
            modelObject.requestCurrentUpdateStart()
        }
        else {
            modelObject.requestCurrentUpdateStop()
        }
    }

    Names {
        id: translations
    }

    TitleBar {
        id: bgTitle

        source: "../../images/common/svg_bolt.svg"
        title: translations.get("ENERGY_TYPE", page.modelObject.energyType)
        anchors {
            left: navigationBar.right
            leftMargin: 20
            top: toolbar.bottom
            right: parent.right
            rightMargin: 10
        }
    }

    SideBar {
        id: bgSideBar

        avgValue: page.averageValue
        cumValue: page.cumulativeValue
        graphType: page.graphType
        value: page.instantValue
        timepoint: page.timepoint

        onTimepointChanged: page.timepoint = dt

        anchors {
            top: bgTitle.bottom
            topMargin: 10
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }
    }

    Item {
        id: bgGraph

        anchors {
            top: bgTitle.bottom
            topMargin: 10
            left: navigationBar.right
            leftMargin: 20
            right: bgSideBar.left
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
        }

        Rectangle {
            anchors.fill: parent
            color: "gray"
            radius: 4
            opacity: 0.5
        }

        ControlBar {
            id: timeValue

            inCurrency: page.inCurrency
            graphVisible: page.graphVisible

            onGraphVisibleChanged: page.graphVisible = visibility
            onInCurrencyChanged: page.inCurrency = value
            onGraphTypeChanged: page.graphType = value

            anchors {
                horizontalCenter: bgGraph.horizontalCenter
                top: parent.top
                topMargin: 10
            }
            height: 30
        }

        Row {
            id: graph
            visible: page.graphVisible

            onChildrenChanged: Helper.updateRowChildren(graph)
            onVisibleChanged: Helper.updateRowChildren(graph)
            onWidthChanged: Helper.updateRowChildren(graph)

            anchors {
                horizontalCenter: bgGraph.horizontalCenter
                top: timeValue.bottom
                topMargin: 10
                bottom: parent.bottom
                bottomMargin: 10
            }
            width: bgGraph.width * 0.98

            Repeater {
                objectName: "repeater" // to skip inside Helper
                model: page.modelGraph
                delegate: graphDelegate
            }

            Component {
                id: graphDelegate

                ControlColumnValue {
                    height: 345
                    levelActual: page.validGraph ? model.modelData.value : 0
                    maxGraphLevel: 100 // TODO come si calcola?
                    levelRed: 90 // TODO come si calcola?
                    lateralBarValue: 80 // TODO da dove si recupera?
                    function formatLabel() {
                        if (page.validGraph)
                        {
                            if (page.graphType === EnergyData.CumulativeDayGraph)
                                // label is "21-21", strip the "-22" part
                                return model.modelData.label.split("-")[0]
                            else
                                return model.modelData.label
                        }
                        else
                            return "---"
                    }

                    label: formatLabel()
                }
            }
        }

        Grid {
            id: sheet
            visible: !page.graphVisible

            anchors {
                horizontalCenter: bgGraph.horizontalCenter
                top: timeValue.bottom
                topMargin: 10
                bottom: parent.bottom
                bottomMargin: 20
            }
            width: bgGraph.width
            columns: 2
            flow: Grid.TopToBottom

            Repeater {
                objectName: "repeater" // to skip inside Helper
                model: page.modelGraph
                delegate: sheetDelegate
            }

            Component {
                id: sheetDelegate

                Rectangle {
                    color: "transparent"
                    width: bgGraph.width / 2
                    height: 20

                    TimeValueItem {
                        id: sheetLabel
                        label: page.validGraph ? model.modelData.label : "---"
                        color: model.modelData.index % 2 === 0 ? "gainsboro" : "silver"
                        width: parent.width / 2 * 0.9
                        anchors {
                            left: parent.left
                            leftMargin: parent.width / 2 * 0.1
                            top: parent.top
                            bottom: parent.bottom
                        }
                    }

                    TimeValueItem {
                        label: page.validGraph ? model.modelData.value : "---"
                        color: model.modelData.index % 2 === 0 ? "gainsboro" : "silver"
                        width: parent.width / 2 * 0.9
                        anchors {
                            left: sheetLabel.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                    }
                }
            }
        }
    }
}
