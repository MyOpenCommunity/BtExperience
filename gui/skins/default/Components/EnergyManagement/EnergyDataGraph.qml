import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../.." // to import Page
import "../../js/Stack.js" as Stack
import "../../js/RowColumnHelpers.js" as Helper


Page {
    id: page

    property variant modelObject
    property int graphType
    property bool graphVisible: true
    property bool inCurrency: false
    property bool validGraph: modelObject.getGraph(page.graphType, timepoint, inCurrency).isValid
    property variant modelGraph: modelObject.getGraph(page.graphType, timepoint, inCurrency).graph
    property variant instantValue: modelObject.getValue(EnergyData.CurrentValue, timepoint, inCurrency)
    property variant cumulativeValue: modelObject.getValue(getValueType(graphType), timepoint, inCurrency).value
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

    Image {
        id: bg
        source: "../../images/scenari.jpg" // TODO mettere lo sfondo giusto
        anchors.fill: parent

        ToolBar {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            fontFamily: semiBoldFont.name
            fontSize: 17
            onHomeClicked: Stack.backToHome()
        }

        Column {
            id: buttonsColumn
            width: backButton.width
            spacing: 10
            anchors {
                top: toolbar.bottom
                left: parent.left
                topMargin: 35
                leftMargin: 20
            }

            ButtonBack {
                id: backButton
                onClicked: Stack.popPage()
            }

            ButtonSystems {
                // 1 is systems page
                onClicked: Stack.showPreviousPage(1)
            }
        }

        TitleBar {
            id: bgTitle

            source: "../../images/common/svg_bolt.svg"
            title: translations.get("ENERGY_TYPE", page.modelObject.energyType)
            anchors {
                left: buttonsColumn.right
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

        Rectangle {
            id: bgGraph
            color: "gray"
            radius: 4
            anchors {
                top: bgTitle.bottom
                topMargin: 10
                left: buttonsColumn.right
                leftMargin: 20
                right: bgSideBar.left
                rightMargin: 10
                bottom: parent.bottom
                bottomMargin: 10
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
                        level_actual: page.validGraph ? model.modelData.value : 0
                        max_graph_level: 100 // TODO come si calcola?
                        level_red: 90 // TODO come si calcola?
                        lateral_bar_value: 80 // TODO da dove si recupera?
                        label: page.validGraph ? model.modelData.label : "---"
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
}
