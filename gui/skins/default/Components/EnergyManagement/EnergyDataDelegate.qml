import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0

Column {
    id: delegate
    property alias description: topText.text
    property variant itemObject: undefined
    property int measureType: EnergyData.Consumption
    property bool isOverview: true

    signal headerClicked(variant mouse)

        QtObject {
        id: privateProps
        property variant monthConsumptionItem: itemObject.getValue(EnergyData.CumulativeMonthValue,
                                                                   new Date(), EnergyData.Consumption)
        property variant goal: monthConsumptionItem !== undefined ? monthConsumptionItem.consumptionGoal : 0.0
        property variant consumption: monthConsumptionItem !== undefined ? monthConsumptionItem.value : 0.0

        function getIcon(energyType) {
            switch (energyType) {
            case EnergyData.Electricity:
                return "../../images/energy/ico_electricity.svg"
            case EnergyData.Water:
                return "../../images/energy/ico_water.svg"
            case EnergyData.Gas:
                return "../../images/energy/ico_gas.svg"
            case EnergyData.HotWater:
                return "../../images/energy/ico_hot_water.svg"
            case EnergyData.Heat:
                return "../../images/energy/ico_heating.svg"
            default:
                console.log("EnergyDataDelegate, unknown energy type (" + energyType + "), use default icon")
                return "../../images/energy/ico_electricity.svg"
            }
        }

        function formatValue(energyType) {
            var energyItem = itemObject.getValue(energyType, new Date(), measureType)
            var value = energyItem.value
            if (value !== undefined) {
                return value.toFixed(energyItem.decimals) + " " + energyItem.measureUnit;
            }
            return "---"
        }

        function maxHeight(columnHeight) {
            return columnHeight * .95
        }

        function idealGoalHeight(columnHeight) {
            return columnHeight * .9
        }

        // the height of goal line. Can be as the "ideal" goal height or less if
        // the consumption height is greater than the maximum height.
        function goalHeight(columnHeight) {
            if (goal === undefined) // the goal line is not shown at all, using hasGoal()
                return 0.0

            var height = consumption / goal * idealGoalHeight(columnHeight)
            if (height > maxHeight(columnHeight))
                return goal / consumption * idealGoalHeight(columnHeight)
            else
                return idealGoalHeight(columnHeight)
        }

        // the height of the consumption bar. It is a value related to the goal
        // height, and it has a maximum value (in the latter case, the goal height
        // is decreased proportionally).
        function getConsumptionHeight(columnHeight) {
            if (consumption === undefined)
                return 0

            if (goal !== undefined) {
                var height = consumption / goal * idealGoalHeight(columnHeight)
                return Math.min(height, maxHeight(columnHeight))
            }
            else {
                // a very simplified representation of the consumption height,
                // proportionally to the days elapsed in the month.
                // TODO: find a better representation!
                var d = new Date()
                return d.getDate() / 30 * idealGoalHeight(columnHeight)
            }
        }

        // return true if the consumption exceed the goal (and, of course, if both are present)
        function consumptionExceedGoal() {
            if (consumption !== undefined && goal !== undefined) {
                if (consumption > goal)
                    return true
            }
            return false
        }

        function hasGoal() {
            return goal !== undefined
        }

    }

    spacing: 5
    ButtonThreeStates {
        defaultImage: "../images/energy/btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"
        pressedImage: "../images/energy/btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"
        shadowImage: "../images/energy/ombra_btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"

        Row {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            SvgImage {
                id: energyIcon
                source: privateProps.getIcon(itemObject.energyType)
            }

            UbuntuLightText {
                id: topText
                font.pixelSize: 14
                text: "electricity"
                color: "#5A5A5A"
            }
        }
        onClicked: delegate.headerClicked(mouse)
    }

    UbuntuLightText {
        font.pixelSize: 18
        text: privateProps.formatValue(EnergyData.CumulativeMonthValue)
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }

    Column {

        SvgImage {
            source: "../../images/energy/colonna" + (isOverview ? '_overview' : '') + ".svg"

            SvgImage {
                anchors.bottom: parent.bottom
                source: {
                    if (privateProps.consumptionExceedGoal()) {
                        "../../images/energy/colonna_rosso" + (isOverview ? '_overview' : '') + ".svg"
                    }
                    else {
                        "../../images/energy/colonna_verde" + (isOverview ? '_overview' : '') + ".svg"
                    }
                }
                height: privateProps.getConsumptionHeight(parent.height)
            }
            SvgImage {
                id: goalLine
                source: "../../images/energy/linea_livello_colonna" + (isOverview ? '_overview' : '') + ".svg"
                visible: privateProps.hasGoal()
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: parent.height - privateProps.goalHeight(parent.height)
            }
        }
        SvgImage {
            source: "../../images/energy/ombra_btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"
        }
    }

    UbuntuLightText {
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        text: "may 2012"
        color: "white"
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        UbuntuLightText {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 14
            text: qsTr("instant consumption")
            color: "white"
        }

        SvgImage {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../../images/energy/bg_instant_consumption.svg"

            UbuntuLightText {
                anchors.centerIn: parent
                font.pixelSize: 14
                text: privateProps.formatValue(EnergyData.CurrentValue)
            }
        }
    }

    Component.onCompleted: itemObject.requestCurrentUpdateStart()
    Component.onDestruction: itemObject.requestCurrentUpdateStop()
}
