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

        Text {
            id: title
            text: qsTr("Consumption Management")
            color: "white"
            x: 195
            y: 65
            font.family: semiBoldFont.name
            font.pixelSize: 36
        }

        EnergyDataOverviewColumn {
            x: 195
            y: 120
            width: 150
            height: 120 + level2 * 1.2
            actual: 135
            level1: 100
            level2: 150
            reference: 200
            title: qsTr("kWh")
            description: qsTr("electricity")
            footer: qsTr("Month (day 21/30)")
            source: "../../images/common/svg_bolt.svg"
        }

        EnergyDataOverviewColumn {
            x: 195 + 150 + 100
            y: 120
            width: 150
            height: 120 + level2 * 1.2
            actual: 18
            level1: 125
            level2: 250
            reference: 300
            title: qsTr("liters")
            description: qsTr("water")
            footer: qsTr("Month (day 21/30)")
            source: "../../images/common/svg_water.svg"
        }

        EnergyDataOverviewColumn {
            x: 195 + (150 + 100) * 2
            y: 120
            width: 150
            height: 120 + level2 * 1.2
            actual: 60
            level1: 20
            level2: 35
            reference: 40
            title: qsTr("liters")
            description: qsTr("heating")
            footer: qsTr("Month (day 21/30)")
            source: "../../images/common/svg_temp.svg"
        }
    }
}
