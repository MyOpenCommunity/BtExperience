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

    EnergyConsumptionLogic {
        id: logic
        monthConsumptionItem: itemObject.getValue(EnergyData.CumulativeMonthValue,
                                                  new Date(), EnergyData.Consumption)
    }

    QtObject {
        id: privateProps

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
    }

    spacing: 5
    ButtonThreeStates {
        defaultImage: "../../images/energy/btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"
        pressedImage: "../../images/energy/btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"
        shadowImage: "../../images/energy/ombra_btn_colonna_grafico" + (isOverview ? '_overview' : '') + ".svg"

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
                    if (logic.consumptionExceedGoal()) {
                        "../../images/energy/colonna_rosso" + (isOverview ? '_overview' : '') + ".svg"
                    }
                    else {
                        "../../images/energy/colonna_verde" + (isOverview ? '_overview' : '') + ".svg"
                    }
                }
                height: logic.getConsumptionSize(parent.height)
            }
            SvgImage {
                id: goalLine
                source: "../../images/energy/linea_livello_colonna" + (isOverview ? '_overview' : '') + ".svg"
                visible: logic.hasGoal()
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: parent.height - logic.goalSize(parent.height)
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
