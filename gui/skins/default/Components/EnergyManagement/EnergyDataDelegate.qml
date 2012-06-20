import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0

Column {
    property alias description: topText.text
    property variant itemObject: undefined
    property int measureType: EnergyData.Consumption

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
        var energy_item = itemObject.getValue(energyType, new Date(), measureType)
        var value = energy_item.value
        if (value !== undefined) {
            return value.toFixed(energy_item.decimals) + " " + energy_item.measureUnit;
        }
        return "---"
    }

    spacing: 5
    ButtonThreeStates {
        defaultImage: "../images/energy/btn_colonna_grafico.svg"
        pressedImage: "../images/energy/btn_colonna_grafico.svg"
        shadowImage: "../images/energy/ombra_btn_colonna_grafico.svg"

        Row {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            SvgImage {
                id: energyIcon
                source: getIcon(itemObject.energyType)
            }

            UbuntuLightText {
                id: topText
                font.pixelSize: 14
                text: "electricity"
                color: "#5A5A5A"
            }
        }
    }

    UbuntuLightText {
        font.pixelSize: 18
        text: formatValue(EnergyData.CumulativeMonthValue)
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }

    Column {
        SvgImage {
            source: "../../images/energy/colonna.svg"

            SvgImage {
                anchors.bottom: parent.bottom
                source: "../../images/energy/colonna_verde_overview.svg"
                // TODO: compute height using a very complicated formula...
                height: 30
            }
        }
        SvgImage {
            source: "../../images/energy/ombra_btn_colonna_grafico.svg"
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
                text: formatValue(EnergyData.CurrentValue)
            }
        }
    }

    Component.onCompleted: itemObject.requestCurrentUpdateStart()
    Component.onDestruction: itemObject.requestCurrentUpdateStop()
}
