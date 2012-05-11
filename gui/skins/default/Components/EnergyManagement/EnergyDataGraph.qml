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


        Rectangle {
            id: bgTitle
            color: "gray"
            height: 90
            radius: 4
            anchors {
                left: buttonsColumn.right
                leftMargin: 20
                top: toolbar.bottom
                right: parent.right
                rightMargin: 10
            }

            SvgImage {
                id: imgTitle
                source: "../../images/common/svg_bolt.svg"
                width: height
                height: 0.8 * parent.height
                anchors {
                    top: parent.top
                    topMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                    left: parent.left
                    leftMargin: 10
                }
            }

            Rectangle {
                color: "transparent"
                height: 0.8 * parent.height
                anchors {
                    top: parent.top
                    topMargin: 5
                    bottom: parent.bottom
                    bottomMargin: 5
                    left: imgTitle.right
                    leftMargin: 10
                }

                EnergyDataTitle {
                    title: translations.get("ENERGY_TYPE", page.modelObject.energyType)
                    anchors {
                        fill: parent
                        centerIn: parent
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            id: bgSideBar
            color: "gray"
            width: 200
            radius: 4
            anchors {
                top: bgTitle.bottom
                topMargin: 10
                right: parent.right
                rightMargin: 10
                bottom: parent.bottom
                bottomMargin: 10
            }

            Column {
                id: sidebar
                spacing: 20
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                onChildrenChanged: Helper.updateColumnChildren(sidebar)
                onVisibleChanged: Helper.updateColumnChildren(sidebar)
                onHeightChanged: Helper.updateColumnChildren(sidebar)

                PeriodItem {
                    width: parent.width * 9 / 10
                    height: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    state: "year"
                }

                Rectangle {
                    id: consumption

                    color: "transparent"
                    width: parent.width * 9 / 10
                    height: 60
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: qsTr("instant consumption")
                        color: "white"
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        color: "light gray"
                        height: 40
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }

                        Text {
                            text: qsTr("45 Wh")
                            color: "black"
                            anchors {
                                fill: parent
                                centerIn: parent
                            }
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ConsumptionBox {
                    state: "cumYear"
                    width: parent.width * 9 / 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    value: 2540
                    maxValue: 3000
                    unit: "kWh"
                }

                ConsumptionBox {
                    state: "avgYear"
                    width: parent.width * 9 / 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    value: 1865
                    maxValue: 3000
                    unit: "kWh"
                }
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

            Row {
                id: timeValue

                onChildrenChanged: Helper.updateRowChildren(timeValue)
                onVisibleChanged: Helper.updateRowChildren(timeValue)
                onWidthChanged: Helper.updateRowChildren(timeValue)

                anchors {
                    horizontalCenter: bgGraph.horizontalCenter
                    top: parent.top
                    topMargin: 10
                }
                height: 30

                TimeValueItem {
                    label: qsTr("time")
                    state: "legend"
                }

                TimeValueItem {
                    id: selDay
                    label: qsTr("day")
                    onClicked: {
                        selDay.state = "selected"
                        selMonth.state = ""
                        selYear.state = ""
                        page.graphType = EnergyData.CumulativeDayGraph
                    }
                }

                TimeValueItem {
                    id: selMonth
                    label: qsTr("month")
                    onClicked: {
                        selDay.state = ""
                        selMonth.state = "selected"
                        selYear.state = ""
                        page.graphType = EnergyData.CumulativeMonthGraph
                    }
                }

                TimeValueItem {
                    id: selYear
                    label: qsTr("year")
                    state: "selected"
                    onClicked: {
                        selDay.state = ""
                        selMonth.state = ""
                        selYear.state = "selected"
                        page.graphType = EnergyData.CumulativeYearGraph
                    }
                }

                TimeValueItem {
                    label: qsTr("value")
                    state: "legend"
                }

                TimeValueItem {
                    id: selEnergy
                    label: qsTr("kWh")
                    state: "selected"
                    onClicked: {
                        selEnergy.state = "selected"
                        selCurrency.state = ""
                    }
                }

                TimeValueItem {
                    id: selCurrency
                    label: qsTr("€")
                    onClicked: {
                        selEnergy.state = ""
                        selCurrency.state = "selected"
                    }
                }

            }

            Row {
                id: graph

                onChildrenChanged: Helper.updateRowChildren(graph)
                onVisibleChanged: Helper.updateRowChildren(graph)
                onWidthChanged: Helper.updateRowChildren(graph)

                property bool valid: page.modelObject.getGraph(page.graphType, new Date()).isValid

                anchors {
                    horizontalCenter: bgGraph.horizontalCenter
                    top: timeValue.bottom
                    topMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                width: bgGraph.width

                Repeater {
                    objectName: "repeater" // to skip inside Helper
                    model: page.modelObject.getGraph(page.graphType, new Date()).graph
                    delegate: graphDelegate
                }

                Component {
                    id: graphDelegate

                    ControlColumnValue {
                        height: 345
                        level_actual: graph.valid ? model.modelData.value : 0 // TODO gestione dati invalidi
                        max_graph_level: 100 // TODO come si calcola?
                        level_red: 90 // TODO come si calcola?
                        lateral_bar_value: 80 // TODO da dove si recupera?
                        label: graph.valid ? model.modelData.label : "---"
                    }
                }
            }
        }
    }
}
