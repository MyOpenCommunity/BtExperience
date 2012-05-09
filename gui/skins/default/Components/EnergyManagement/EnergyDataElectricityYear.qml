import QtQuick 1.1
import Components 1.0
import "../.." // to import Page
import "../../js/Stack.js" as Stack


Page {
    id: page

    function _updateRowChildren(row, spacing) {
        for(var i = 0; i < children.length; i++) {
            var child = children[i];
            var availableWidth = row.width - (children.length - 1) * spacing
            child.width = availableWidth / children.length
        }
    }

    function _updateColumnChildren(column, spacing) {
        for(var i = 0; i < children.length; i++) {
            var child = children[i];
            var availableHeight = column.height - (children.length - 1) * spacing
            child.height = availableHeight / children.length
        }
    }

    Image {
        id: bg
        source: "../../images/scenari.jpg"
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
                Text {
                    text: qsTr("Overall")
                    color: "white"
                    anchors {
                        fill: parent
                        centerIn: parent
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: semiBoldFont.name
                        pixelSize: 36
                    }
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
                spacing: 30
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                onChildrenChanged: _updateColumnChildren(sidebar, spacing)
                onVisibleChanged: _updateColumnChildren(sidebar, spacing)
                onHeightChanged: _updateColumnChildren(sidebar, spacing)

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

                onChildrenChanged: _updateRowChildren(timeValue, spacing)
                onVisibleChanged: _updateRowChildren(timeValue, spacing)
                onWidthChanged: _updateRowChildren(timeValue, spacing)

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
                    label: qsTr("day")
                }

                TimeValueItem {
                    label: qsTr("month")
                    state: "selected"
                }

                TimeValueItem {
                    label: qsTr("year")
                }

                TimeValueItem {
                    label: qsTr("value")
                    state: "legend"
                }

                TimeValueItem {
                    label: qsTr("kWh")
                    state: "selected"
                }

                TimeValueItem {
                    label: qsTr("€")
                }

            }

            Row {
                id: graph

                onChildrenChanged: _updateRowChildren(graph, spacing)
                onVisibleChanged: _updateRowChildren(graph, spacing)
                onWidthChanged: _updateRowChildren(graph, spacing)

                anchors {
                    horizontalCenter: bgGraph.horizontalCenter
                    top: timeValue.bottom
                    topMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 200
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("january")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 160
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("february")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 75
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 120
                    label: qsTr("march")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 200
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("april")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 160
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("may")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 75
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 120
                    label: qsTr("june")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 200
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("july")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 160
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("august")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 75
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 120
                    label: qsTr("september")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 200
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("october")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 160
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 80
                    label: qsTr("november")
                }

                ControlColumnValue {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    level_actual: 75
                    max_graph_level: 200
                    level_red: 100
                    lateral_bar_value: 120
                    label: qsTr("december")
                }
            }
        }
    }
}
