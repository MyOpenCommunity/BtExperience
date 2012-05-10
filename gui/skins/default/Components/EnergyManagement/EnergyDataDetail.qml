import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../.." // to import Page
import "../../js/Stack.js" as Stack
import "../../js/RowColumnHelpers.js" as Helper


Page {
    id: page

    property variant modelObject

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

            EnergyDataTitle {
                title: translations.get("ENERGY_TYPE", modelObject.energyType)
                anchors.left: parent.left
            }

            Row {
                id: energyCategories
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 50
                height: 345

                EnergyDataElectricityColumn {
                    width: 100
                    level_actual: 135
                    level_critical: 150
                    perc_warning: 0.8
                    title: level_actual + " " + qsTr("kWh")
                    description: "overall"
                    footer: qsTr("day 21/30")
                    source: "../../images/common/svg_bolt.svg"
                    note_header: "consumption"
                    note_footer: 45 + " " + qsTr("W")
                    critical_bar_visible: true
                }

                EnergyDataElectricityColumn {
                    width: 100
                    level_actual: 83
                    level_critical: 150
                    perc_warning: 0.8
                    title: level_actual + " " + qsTr("kWh")
                    description: "lights"
                    footer: qsTr("day 21/30")
                    source: "../../images/common/svg_bolt.svg"
                    note_header: "consumption"
                    note_footer: 15 + " " + qsTr("W")
                }

                EnergyDataElectricityColumn {
                    width: 100
                    level_actual: 25
                    level_critical: 150
                    perc_warning: 0.8
                    title: level_actual + " " + qsTr("kWh")
                    description: "appliances"
                    footer: qsTr("day 21/30")
                    source: "../../images/common/svg_bolt.svg"
                    note_header: "consumption"
                    note_footer: 10 + " " + qsTr("W")
                }

                EnergyDataElectricityColumn {
                    width: 100
                    level_actual: 7
                    level_critical: 150
                    perc_warning: 0.8
                    title: level_actual + " " + qsTr("kWh")
                    description: "office"
                    footer: qsTr("day 21/30")
                    source: "../../images/common/svg_bolt.svg"
                    note_header: "consumption"
                    note_footer: 8 + " " + qsTr("W")
                }

                EnergyDataElectricityColumn {
                    width: 100
                    level_actual: 20
                    level_critical: 150
                    perc_warning: 0.8
                    title: level_actual + " " + qsTr("kWh")
                    description: "garden"
                    footer: qsTr("day 21/30")
                    source: "../../images/common/svg_bolt.svg"
                    note_header: "consumption"
                    note_footer: 6 + " " + qsTr("W")
                }
            }

            Row {
                anchors.horizontalCenter: energyCategories.horizontalCenter
                height: 30
                Rectangle {
                    color: "light grey"
                    width: 100
                    height: parent.height
                    Text {
                        text: qsTr("day")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("obj: "+page.modelObject)
                    }
                }
                Rectangle {
                    color: "dark grey"
                    width: 100
                    height: parent.height
                    Text {
                        text: qsTr("month")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle {
                    color: "light grey"
                    width: 100
                    height: parent.height
                    Text {
                        text: qsTr("year")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

            }

        }
    }
}
