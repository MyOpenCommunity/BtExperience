import QtQuick 1.1
import Components 1.0
import "../.." // to import Page
import "../../js/Stack.js" as Stack


Page {
    id: page

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

        Column {
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
                text: qsTr("Consumption Management")
                color: "white"
                anchors.left: parent.left
                font.family: semiBoldFont.name
                font.pixelSize: 36
            }

            Item {
                id: energyCategories
                anchors.left: parent.left
                anchors.right: parent.right
                height: 345

                EnergyDataOverviewColumn {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 150
                    level_actual: 135
                    perc_warning: 0.8
                    level_critical: 150
                    title: level_actual + " " + qsTr("kWh")
                    description: qsTr("electricity")
                    footer: qsTr("Month (day 21/30)")
                    source: "../../images/common/svg_bolt.svg"
                    onClicked: Stack.openPage("Components/EnergyManagement/EnergyDataElectricity.qml")
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Stack.openPage("Components/EnergyManagement/EnergyDataElectricityYear.qml")
                    }
                }

                EnergyDataOverviewColumn {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 150
                    level_actual: 18
                    perc_warning: 0.8
                    level_critical: 250
                    title: level_actual + " " + qsTr("liters")
                    description: qsTr("water")
                    footer: qsTr("Month (day 21/30)")
                    source: "../../images/common/svg_water.svg"
                }

                EnergyDataOverviewColumn {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 150
                    level_actual: 60
                    perc_warning: 0.8
                    level_critical: 35
                    title: level_actual + " " + qsTr("liters")
                    description: qsTr("heating")
                    footer: qsTr("Month (day 21/30)")
                    source: "../../images/common/svg_temp.svg"
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
                        text: qsTr("daily")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle {
                    color: "dark grey"
                    width: 100
                    height: parent.height
                    Text {
                        text: qsTr("montly")
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
