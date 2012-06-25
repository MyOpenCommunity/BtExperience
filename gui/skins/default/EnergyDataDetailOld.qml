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
    property int valueType
    property string keyString

    function systemsButtonClicked() {
        Stack.showPreviousPage(1)
    }

    Names {
        id: translations
    }

    Component.onCompleted: {
        for (var i = 0; i < modelEnergy.count; ++i) {
            // at page load completion we start all update requests
            modelEnergy.getObject(i).requestCurrentUpdateStart()
        }
    }

    onVisibleChanged: {
        // when visibility changes, we modify all update requests
        // note that on destruction our Stack.js code makes the page
        // invisible, so we must not stop updates on destruction otherwise
        // we get errors while navigating back and forth a page
        for (var i = 0; i < modelEnergy.count; ++i)
            if (visible) {
                modelEnergy.getObject(i).requestCurrentUpdateStart()
            }
            else {
                modelEnergy.getObject(i).requestCurrentUpdateStop()
            }
    }


    anchors.fill: parent
    text: translations.get("ENERGY_TYPE", page.modelObject.energyType)
    showSystemsButton: true

    Column {
        id: panel
        spacing: 40
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.top: toolbar.bottom
        anchors.topMargin: parent.height / 100 * 15
        anchors.right: parent.right
        anchors.rightMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height / 100 * 5

        Row {
            id: energyDetails

            anchors {
                horizontalCenter: panel.horizontalCenter
                horizontalCenterOffset: (panel.anchors.leftMargin - panel.anchors.rightMargin) / 2.0
            }
            spacing: 80
            width: panel.width

            onChildrenChanged: Helper.updateRowChildren(energyDetails)
            onVisibleChanged: Helper.updateRowChildren(energyDetails)
            onWidthChanged: Helper.updateRowChildren(energyDetails)

            Repeater {
                objectName: "repeater" // to skip inside Helper
                // TODO come recupero le linee? nota: il modello deve
                // comprendere anche il generale!
                model: ObjectModel {
                    id: modelEnergy
                    filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: page.keyString}]
                }
                delegate: energyDetailsDelegate
            }

            Component {
                id: energyDetailsDelegate

                EnergyDataDetailColumn {

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

                    function openLinkedPage(obj) {
                        Stack.openPage("EnergyDataGraphOld.qml", {"modelObject": obj,"graphType": EnergyData.CumulativeYearGraph})
                    }

                    function dummy(d) {
                        // this function is useful only to bind i to page.valueType
                        // in this way the value is updated every time the
                        // page.valueType is updated
                        // TODO this function must receive updates from object
                        // when they arrive
                        return EnergyData.CurrentValue
                    }

                    height: 345
                    // TODO recuperare il generale e le linee
                    property variant obj: modelEnergy.getObject(index)
                    property variant v: obj.getValue(page.valueType, new Date())
                    property variant i: obj.getValue(dummy(page.valueType), new Date())
                    level_actual: v.isValid ? v.value : 0
                    perc_warning: 0.8
                    level_critical: 90 // TODO it must come from somewhere
                    title: level_actual + " " + translations.get("ENERGY_UNIT", obj.energyType)
                    source: getSymbol(obj.energyType)
                    valueType: page.valueType
                    description: translations.get("ENERGY_TYPE", obj.energyType) // TODO implementare
                    note_header: "consumption"
                    note_footer: (i.isValid ? i.value + " " + translations.get("ENERGY_UNIT", obj.energyType) : "---")
                    critical_bar_visible: index === 0 ? true : false // TODO assumes the total is first column
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
                    page.valueType = EnergyData.CumulativeDayValue
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
                    page.valueType = EnergyData.CumulativeMonthValue
                }
            }

            TimeValueItem {
                id: selYear
                label: qsTr("year")
                onClicked: {
                    selDay.state = ""
                    selMonth.state = ""
                    selYear.state = "selected"
                    page.valueType = EnergyData.CumulativeYearValue
                }
            }
        }
    }
}
