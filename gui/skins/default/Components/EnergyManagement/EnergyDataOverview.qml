import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../.." // to import Page
import "../../js/Stack.js" as Stack
import "../../js/RowColumnHelpers.js" as Helper


Page {
    id: page
    source: "../../images/scenari.jpg" // TODO mettere lo sfondo giusto

    Names {
        id: translations
    }

    FilterListModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: "general"}]
    }

        ToolBar {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // TODO mettere le seguenti voci direttamente dentro ToolBar?
            fontFamily: semiBoldFont.name
            fontSize: 17
            onHomeClicked: Stack.backToHome()
        }

        NavigationBar {
            id: buttonsColumn
            anchors {
                top: toolbar.bottom
                left: parent.left
                topMargin: 31
                leftMargin: 2
            }

            onBackClicked: Stack.popPage()
            onSystemsClicked: Stack.showPreviousPage(1)
        }

        Column {
            id: panel
            spacing: 40
            anchors.left: parent.left
            anchors.leftMargin: 195
            anchors.top: toolbar.bottom
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 150
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30

            EnergyDataTitle {
                title: translations.get("ENERGY_TYPE", "Consumption Management")
                anchors.left: parent.left
            }

            Row {
                id: energyCategories

                property int valueType: EnergyData.CumulativeMonthValue

                anchors {
                    horizontalCenter: panel.horizontalCenter
                    horizontalCenterOffset: (panel.anchors.leftMargin - panel.anchors.rightMargin) / 2.0
                }
                spacing: 80
                width: panel.width

                onChildrenChanged: Helper.updateRowChildren(energyCategories)
                onVisibleChanged: Helper.updateRowChildren(energyCategories)
                onWidthChanged: Helper.updateRowChildren(energyCategories)

                Repeater {
                    id: repeaterElement
                    objectName: "repeater" // to skip inside Helper
                    model: energiesCounters
                    delegate: energyCategoriesDelegate
                }

                Component {
                    id: energyCategoriesDelegate

                    EnergyDataOverviewColumn {

                        function getSymbol(t) {
                            if (t === EnergyData.Electricity)
                                return "../../images/common/svg_bolt.svg"
                            else if (t === EnergyData.Water)
                                return "../../images/common/svg_water.svg"
                            // TODO add images
                            //                    else if (t === EnergyData.Gas)
                            //                        return "../../images/common/svg_gas.svg"
                            //                    else if (t === EnergyData.HotWater)
                            //                        return "../../images/common/svg_hot_water.svg"
                            else if (t === EnergyData.Heat)
                                return "../../images/common/svg_temp.svg"
                            //                            else if (t === EnergyData.???)
                            //                                return "../../images/common/svg_???.svg"
                            return "../../images/common/svg_bolt.svg"
                        }

                        function getKeyString(t) {
                            if (t === EnergyData.Electricity)
                                return "Electricity"
                            else if (t === EnergyData.Water)
                                return "Water"
                            else if (t === EnergyData.Gas)
                                return "Gas"
                            else if (t === EnergyData.HotWater)
                                return "HotWater"
                            else if (t === EnergyData.Heat)
                                return "Heat"
                            //                            else if (t === EnergyData.???)
                            //                                return "???"
                            return "Electricity"
                        }

                        function openLinkedPage(obj) {
                            Stack.openPage("Components/EnergyManagement/EnergyDataDetail.qml", {"modelObject": obj,"valueType": energyCategories.valueType, "keyString": getKeyString(obj.energyType)})
                        }

                        height: 345
                        property variant obj: repeaterElement.model.getObject(index)
                        property variant v: obj.getValue(energyCategories.valueType, new Date())
                        level_actual: v.isValid ? v.value : 0
                        perc_warning: 0.8
                        level_critical: 90 // TODO it must come from somewhere
                        title: level_actual + " " + translations.get("ENERGY_UNIT", obj.energyType)
                        description: translations.get("ENERGY_TYPE", obj.energyType)
                        valueType: energyCategories.valueType
                        source: getSymbol(obj.energyType)
                        onClicked: openLinkedPage(obj)
                    }
                }
            }

            Row {
                anchors {
                    horizontalCenter: panel.horizontalCenter
                    horizontalCenterOffset: (panel.anchors.leftMargin - panel.anchors.rightMargin) / 2.0
                }
                height: 30
                width: 300
                spacing: 1

                TimeValueItem {
                    id: selDay
                    label: qsTr("day")
                    onClicked: {
                        selDay.state = "selected"
                        selMonth.state = ""
                        selYear.state = ""
                        energyCategories.valueType = EnergyData.CumulativeDayValue
                    }
                }

                TimeValueItem {
                    id: selMonth
                    label: qsTr("month")
                    state: "selected"
                    onClicked: {
                        selDay.state = ""
                        selMonth.state = "selected"
                        selYear.state = ""
                        energyCategories.valueType = EnergyData.CumulativeMonthValue
                    }
                }

                TimeValueItem {
                    id: selYear
                    label: qsTr("year")
                    onClicked: {
                        selDay.state = ""
                        selMonth.state = ""
                        selYear.state = "selected"
                        energyCategories.valueType = EnergyData.CumulativeYearValue
                    }
                }

            }

        }
}
