import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../.." // to import Page
import "../../js/Stack.js" as Stack
import "../../js/RowColumnHelpers.js" as Helper


Page {
    id: page

    Names {
        id: translations
    }

    FilterListModel {
        id: modelEnergy
        filters: [{objectId: ObjectInterface.IdEnergyData}]
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
            // TODO mettere le seguenti voci direttamente dentro ToolBar?
            fontFamily: semiBoldFont.name
            fontSize: 17
            onHomeClicked: Stack.backToHome()
        }

        Column {
            // TODO se la toolbar laterale è la stessa ovunque perché non creare un componente?
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

            Text {
                id: title
                text: translations.get("ENERGY_TYPE", "Consumption Management")
                color: "white"
                anchors.left: parent.left
                font.family: semiBoldFont.name
                font.pixelSize: 36
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
                    objectName: "repeater" // to skip inside Helper
                    model: modelEnergy
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

                        function openLinkedPage(t) {
                            if (t === EnergyData.Electricity)
                                Stack.openPage("Components/EnergyManagement/EnergyDataElectricity.qml")
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

                        height: 345
                        property variant obj: modelEnergy.getObject(index)
                        property variant v: obj.getValue(energyCategories.valueType, new Date())
                        level_actual: v.isValid ? v.value : 0 // TODO manage invalid values
                        perc_warning: 0.8
                        level_critical: 90 // TODO it must come from somewhere
                        title: level_actual + " " + translations.get("ENERGY_UNIT", obj.energyType)
                        description: translations.get("ENERGY_TYPE", obj.energyType)
                        footer: qsTr("Month (day 21/30)") // TODO ???
                        source: getSymbol(obj.energyType)
                        onClicked: openLinkedPage(obj.energyType)
                    }
                }
            }

            Row {
                anchors.horizontalCenter: panel.horizontalCenter
                anchors.horizontalCenterOffset: (panel.anchors.leftMargin - panel.anchors.rightMargin) / 2.0
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
}
