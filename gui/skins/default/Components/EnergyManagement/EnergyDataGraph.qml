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
    property bool validGraph: modelObject.getGraph(page.graphType, timepoint).isValid
    property variant modelGraph: modelObject.getGraph(page.graphType, timepoint).graph
    property variant instantValue: modelObject.getValue(dummy(graphType), timepoint)
    property variant cumulativeValue: modelObject.getValue(getValueType(graphType), timepoint).value
    property variant averageValue: cumulativeValue / 10 // TODO come si calcola?
    property date timepoint: new Date()

    function dummy(d) {
        // TODO receive instant values from object when they arrive
        return EnergyData.CurrentValue
    }

    function getValueType(g) {
        if (g === EnergyData.CumulativeDayGraph)
            return EnergyData.CumulativeDayValue
        else if (g === EnergyData.CumulativeMonthGraph)
            return EnergyData.CumulativeMonthValue
        else if (g === EnergyData.CumulativeYearGraph)
            return EnergyData.CumulativeYearValue
    }

    function getTimepoint(d) {
        if (page.graphType === EnergyData.CumulativeDayGraph)
            return Qt.formatDateTime(page.timepoint, "dd/MM/yyyy")
        else if (page.graphType === EnergyData.CumulativeMonthGraph)
            return Qt.formatDateTime(page.timepoint, "MM/yyyy")
        else if (page.graphType === EnergyData.CumulativeYearGraph)
            return Qt.formatDateTime(page.timepoint, "yyyy")
    }

    function getTimeInterval(d) {
        if (page.graphType === EnergyData.CumulativeDayGraph)
            return "day"
        else if (page.graphType === EnergyData.CumulativeMonthGraph)
            return "month"
        else if (page.graphType === EnergyData.CumulativeYearGraph)
            return "year"
    }

    function plusTimepoint() {
        if (page.graphType === EnergyData.CumulativeDayGraph) {
            var d = new Date(page.timepoint)
            d.setDate(d.getDate() + 1)
            page.timepoint = new Date(d)
        }
        else if (page.graphType === EnergyData.CumulativeMonthGraph) {
            var m = new Date(page.timepoint)
            m.setMonth(m.getMonth() + 1)
            page.timepoint = new Date(m)
        }
        else if (page.graphType === EnergyData.CumulativeYearGraph) {
            var y = new Date(page.timepoint)
            y.setFullYear(y.getFullYear() + 1)
            page.timepoint = new Date(y)
        }
    }

    function minusTimepoint() {
        if (page.graphType === EnergyData.CumulativeDayGraph) {
            var d = new Date(page.timepoint)
            d.setDate(d.getDate() - 1)
            page.timepoint = new Date(d)
        }
        else if (page.graphType === EnergyData.CumulativeMonthGraph) {
            var m = new Date(page.timepoint)
            m.setMonth(m.getMonth() - 1)
            page.timepoint = new Date(m)
        }
        else if (page.graphType === EnergyData.CumulativeYearGraph) {
            var y = new Date(page.timepoint)
            y.setFullYear(y.getFullYear() - 1)
            page.timepoint = new Date(y)
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
                    timepoint: getTimepoint(page.timepoint)
                    state: getTimeInterval(page.timepoint)
                    onMinusClicked: minusTimepoint()
                    onPlusClicked: plusTimepoint()
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
                            text: (instantValue.isValid ? instantValue.value : 0) + " " + qsTr("Wh")
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
                    id: cumulativeConsumption
                    state: "cumYear"
                    width: parent.width * 9 / 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    // TODO implementare (il valore recuperato è corretto?)
                    value: page.cumulativeValue
                    // TODO da dove si recupera il valore max?
                    maxValue: 120
                    unit: "kWh"
                }

                ConsumptionBox {
                    id: averageConsumption
                    state: "avgYear"
                    width: parent.width * 9 / 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    // TODO implementare (come si recupera il valore medio sul periodo?)
                    value: page.averageValue
                    // TODO da dove si recupera il valore max?
                    maxValue: 120
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
                        cumulativeConsumption.state = "cumDay"
                        averageConsumption.state = "avgDay"
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
                        cumulativeConsumption.state = "cumMonth"
                        averageConsumption.state = "avgMonth"
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
                        cumulativeConsumption.state = "cumYear"
                        averageConsumption.state = "avgYear"
                    }
                }

                TimeValueItem {
                    label: qsTr("")
                    state: "legend"
                }

                TimeValueItem {
                    id: selUnit
                    label: page.modelObject.tariff === 0 ? qsTr("euro") : qsTr("kWh")
                    onClicked: page.modelObject.tariff = (page.modelObject.tariff + 1) % 2
                }

                TimeValueItem {
                    id: selGraph
                    label: page.graphVisible ? qsTr("sheet") : qsTr("graph")
                    onClicked: page.graphVisible = !page.graphVisible
                }

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
                        level_actual: page.validGraph ? model.modelData.value : 0 // TODO gestione dati invalidi
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
                            label: page.validGraph ? model.modelData.value : 0 // TODO gestione dati invalidi
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
