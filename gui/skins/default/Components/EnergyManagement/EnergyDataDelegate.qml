/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0


Column {
    id: delegate
    property variant itemObject: undefined
    property int measureType: EnergyData.Consumption
    property real maxValue: -1

    // for CardView usage
    property int index: -1
    property variant view
    property alias moveAnimationRunning: defaultAnimation.running

    signal touched
    signal removeAnimationFinished // for CardView usage

    EnergyFunctions {
        id: energyFunctions
    }

    EnergyItemObject {
        id: consumptionValue
        energyData: delegate.itemObject
        valueType: EnergyData.CumulativeMonthValue
        date: new Date()
        measureType: EnergyData.Consumption
    }

    EnergyItemObject {
        id: currentConsumptionValue
        energyData: delegate.itemObject
        valueType: EnergyData.CurrentValue
        date: new Date()
        measureType: delegate.measureType
    }

    EnergyItemObject {
        id: monthConsumptionValue
        energyData: delegate.itemObject
        valueType: EnergyData.CumulativeMonthValue
        date: new Date()
        measureType: delegate.measureType
    }

    QtObject {
        id: privateProps

        property variant consumptionObj: consumptionValue.item
        property variant currentConsumptionObj: currentConsumptionValue.item
        property variant monthConsumptionObj: monthConsumptionValue.item

        function hasGoal() {
            return consumptionObj.goalEnabled && consumptionObj.consumptionGoal > 0.0
        }

        property bool bannerVisualization: (itemObject.familyType === EnergyFamily.Custom && !hasGoal())

        property real scaleFactor: 0.8 // the percentage of the height to not overcome
    }

    spacing: 5
    onHeightChanged: delegate.view.height = Math.max(delegate.view.height, height) // for CardView usage

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
                source: "../../images/energy/" + energyFunctions.getIcon(itemObject.energyType, headerButton.state == "pressed")
            }

            UbuntuLightText {
                id: topText
                text: itemObject.name
                font.pixelSize: 14
                color: headerButton.state === "pressed" ? "white" : "#5A5A5A"
            }
        }
        onTouched: delegate.touched()
    }


    Item {
        visible: privateProps.bannerVisualization
        width: parent.width
        height: 8
    }

    Loader {
        sourceComponent: privateProps.bannerVisualization ? energyBannerComponent : energyStackComponent
    }

    Component {
        id: energyBannerComponent
        Item {
            height: consumptionLabel.height + bg.height
            width: delegate.width

            UbuntuLightText {
                id: consumptionLabel
                font.pixelSize: 14
                text: qsTr("cumulative consumption")
                color: "white"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            SvgImage {
                id: bg
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: consumptionLabel.bottom
                source: "../../images/energy/bg_instant_consumption.svg"

                UbuntuLightText {
                    anchors.centerIn: parent
                    font.pixelSize: 18
                    color: "grey"
                    text: energyFunctions.formatValue(privateProps.monthConsumptionObj)
                }
            }
        }
    }

    Component {
        id: energyStackComponent
        Column {
            spacing: delegate.spacing

            Item {
                height: consumptionObjText.font.pixelSize + 4
                anchors {
                    left: parent.left
                    right: parent.right
                }

                UbuntuLightText {
                    id: consumptionObjText
                    font.pixelSize: 18
                    text: energyFunctions.formatValue(privateProps.monthConsumptionObj)
                    anchors.centerIn: parent
                    color: "white"
                }
            }

            Column {
                Item {
                    BeepingMouseArea {
                        anchors.fill: parent
                        onClicked: delegate.touched()
                    }

                    width: columnBg.width
                    height: columnBg.height

                    SvgImage {
                        id: columnBg
                        opacity: 0.2
                        source: "../../images/energy/colonna.svg"
                        visible: privateProps.hasGoal()
                    }

                    SvgImage {
                        anchors.bottom: parent.bottom
                        source: {
                            if (privateProps.hasGoal() &&
                                privateProps.consumptionObj.value > privateProps.consumptionObj.consumptionGoal) {
                                return "../../images/energy/colonna_rosso.svg"
                            }
                            else {
                                return "../../images/energy/colonna_verde.svg"
                            }
                        }
                        height: {
                            if (!privateProps.consumptionObj.isValid)
                                return 0
                            return privateProps.consumptionObj.value / delegate.maxValue * parent.height * privateProps.scaleFactor
                        }
                    }

                    SvgImage {
                        id: goalLine
                        source: "../../images/energy/linea_livello_colonna.svg"
                        visible: privateProps.hasGoal()
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: {
                            var goalHeight = 0
                            if (privateProps.consumptionObj.isValid)
                                goalHeight = privateProps.consumptionObj.consumptionGoal / delegate.maxValue * parent.height * privateProps.scaleFactor
                            return parent.height - goalHeight
                        }
                    }
                }

                SvgImage {
                    source: "../../images/energy/ombra_btn_colonna_grafico.svg"
                }
            }
        }
    }


    UbuntuLightText {
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        text: Qt.formatDate(privateProps.consumptionObj.date, "MMM yyyy")
        color: "white"
    }

    Item {
        visible: privateProps.bannerVisualization
        width: parent.width
        height: 10
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
                color: energyFunctions.getColor(privateProps.currentConsumptionObj)
                text: energyFunctions.formatValue(privateProps.currentConsumptionObj)
            }
        }
    }

    Connections {
        target: global.screenState
        onStateChangedInt: {
            if (energyFunctions.automaticUpdatesEnabled(old_state) &&
                    !energyFunctions.automaticUpdatesEnabled(new_state))
                itemObject.requestCurrentUpdateStop()
            else if (!energyFunctions.automaticUpdatesEnabled(old_state) &&
                     energyFunctions.automaticUpdatesEnabled(new_state))
                itemObject.requestCurrentUpdateStart()
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
