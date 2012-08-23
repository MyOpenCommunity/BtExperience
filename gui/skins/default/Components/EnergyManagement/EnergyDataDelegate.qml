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
    // for CardView usage
    property int index: -1
    property variant view
    property alias moveAnimationRunning: defaultAnimation.running

    signal headerClicked(variant mouse)
    signal removeAnimationFinished() // for CardView usage

    QtObject {
        id: privateProps

        function getIcon(energyType, state) {
            switch (energyType) {
            case EnergyData.Water:
                return state === "pressed" ? "../../images/energy/ico_water_p.svg" : "../../images/energy/ico_water.svg"
            case EnergyData.Gas:
                return state === "pressed" ? "../../images/energy/ico_gas_p.svg" : "../../images/energy/ico_gas.svg"
            case EnergyData.HotWater:
                return state === "pressed" ? "../../images/energy/ico_hot_water_p.svg" : "../../images/energy/ico_hot_water.svg"
            case EnergyData.Heat:
                return state === "pressed" ? "../../images/energy/ico_heating_p.svg" : "../../images/energy/ico_heating.svg"
            default:
                if (energyType !== EnergyData.Electricity)
                    console.log("EnergyDataDelegate, unknown energy type (" + energyType + "), use default icon")
                return state === "pressed" ?  "../../images/energy/ico_electricity_p.svg" : "../../images/energy/ico_electricity.svg"
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
    onHeightChanged: delegate.view.height = height // for CardView usage

    ButtonThreeStates {
        id: headerButton
        defaultImage: "../../images/energy/btn_colonna_grafico.svg"
        pressedImage: "../../images/energy/btn_colonna_grafico_p.svg"
        shadowImage: "../../images/energy/ombra_btn_colonna_grafico.svg"

        Row {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            SvgImage {
                id: energyIcon
                source: privateProps.getIcon(itemObject.energyType, headerButton.state)
            }

            UbuntuLightText {
                id: topText
                font.pixelSize: 14
                text: "electricity"
                color: headerButton.state === "pressed" ? "white" : "#5A5A5A"
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

    EnergyConsumptionLogic {
        id: logic
        monthConsumptionItem: itemObject.getValue(EnergyData.CumulativeMonthValue,
                                                  new Date(), EnergyData.Consumption)
    }

    Column {
        Item {
            width: columnBg.width
            height: columnBg.height
            SvgImage {
                id: columnBg
                opacity: 0.2
                source: "../../images/energy/colonna.svg"
                visible: logic.hasGoal()
            }
            SvgImage {
                anchors.bottom: parent.bottom
                source: {
                    if (logic.consumptionExceedGoal()) {
                        return "../../images/energy/colonna_rosso.svg"
                    }
                    else {
                        return "../../images/energy/colonna_verde.svg"
                    }
                }
                height: logic.getConsumptionSize(parent.height)
            }
            SvgImage {
                id: goalLine
                source: "../../images/energy/linea_livello_colonna.svg"
                visible: logic.hasGoal()
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: parent.height - logic.goalSize(parent.height)
            }
        }

        SvgImage {
            source: "../../images/energy/ombra_btn_colonna_grafico.svg"
        }
    }

    UbuntuLightText {
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        text: Qt.formatDate(logic.monthConsumptionItem.date, "MMM yyyy")
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
                font.pixelSize: 18
                text: privateProps.formatValue(EnergyData.CurrentValue)
            }
        }
    }

    Component.onCompleted: itemObject.requestCurrentUpdateStart()
    Component.onDestruction: itemObject.requestCurrentUpdateStop()

    // for CardView usage
    states: [
        State {
            name: "remove"
        }
    ]

    transitions:
        Transition {
            from: "*"
            to: "remove"
            SequentialAnimation {
                NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InSine }
                ScriptAction { script: delegate.removeAnimationFinished() }
            }
        }

    Behavior on x {
        NumberAnimation { id: defaultAnimation; duration: 300; easing.type: Easing.InSine }
    }
}
