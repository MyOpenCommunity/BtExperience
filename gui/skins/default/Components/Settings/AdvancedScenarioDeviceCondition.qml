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
    id: column
    property variant scenarioDeviceObject

    width: line.width
    spacing: 10

    UbuntuMediumText {
        text: qsTr("device condition")
        width: line.width
        elide: Text.ElideRight
        font.pixelSize: 18
        color: "white"

    }
    SvgImage {
        id: line
        source: "../../images/common/linea.svg"
    }

    UbuntuLightText {
        id: deviceDescription
        text: scenarioDeviceObject.description
        width: line.width
        elide: Text.ElideRight
        font.pixelSize: 14
        color: "white"
    }

    Loader {
        sourceComponent: scenarioDeviceObject.onOff !== undefined ? controlOnOffComponent : undefined
        height: controlRadioPrototype.height
        width: line.width
    }


    ControlRadio {
        id: controlRadioPrototype
        visible: false
        text: qsTr("ON")
    }

    Component {
        id: controlOnOffComponent
        Row {
            spacing: 13
            Repeater {
                model: ListModel {
                    id: statusModel
                    Component.onCompleted: {
                        statusModel.append({"text": qsTr("ON"), "value": true})
                        statusModel.append({"text": qsTr("OFF"), "value": false})
                    }
                }

                ControlRadio {
                   status: scenarioDeviceObject.onOff === model.value
                   text: model.text
                   onPressed: scenarioDeviceObject.onOff = model.value
                }
            }
        }
    }


    Item { // a spacer
        height: 10
        width: line.width
    }

    Loader {
        sourceComponent: scenarioDeviceObject.rangeValues.length > 0 ? controlSpinComponent : undefined
    }

    Component {
        id: controlSpinComponent
        Item {
            id: spinItem

            function rangeDescription(type) {
                if (type === DeviceConditionObject.Dimming || type === DeviceConditionObject.Dimming100)
                    return qsTr("Intensity")

                if (type === DeviceConditionObject.Amplifier)
                    return qsTr("Volume")

                if (type === DeviceConditionObject.Probe || type === DeviceConditionObject.ExternalProbe || type === DeviceConditionObject.Temperature)
                    return qsTr("Temperature")
            }

            function representValues(values, type) {

                if (type === DeviceConditionObject.Dimming || type === DeviceConditionObject.Dimming100 || type === DeviceConditionObject.Amplifier)
                    return values[0] + ' - ' + values[1] + "%"

                if (type === DeviceConditionObject.Probe || type === DeviceConditionObject.ExternalProbe || type === DeviceConditionObject.Temperature)
                    return values[0].toFixed(1) + qsTr("\272C")

                return ''
            }

            width: controlSpin.width
            height: rangeText.height + controlSpin.height
            Rectangle {
                z: 1
                anchors.fill: controlSpin
                color: "silver"
                opacity: 0.6
                visible: scenarioDeviceObject.onOff === false
                MouseArea {
                    anchors.fill: parent // blocks events
                }
            }

            UbuntuLightText {
                id: rangeText
                text: spinItem.rangeDescription(scenarioDeviceObject.type)
                font.pixelSize: 14
                color: "white"
            }

            ControlSpin {
                id: controlSpin
                anchors {
                    top: rangeText.bottom
                    topMargin: column.spacing
                }

                text: spinItem.representValues(scenarioDeviceObject.rangeValues, scenarioDeviceObject.type)
                repetitionWithSlowFastClicks: true
                onMinusClicked: scenarioDeviceObject.conditionDown()
                onMinusClickedSlow: scenarioDeviceObject.conditionDown()
                onMinusClickedFast: scenarioDeviceObject.conditionDownHeld()
                onPlusClicked: scenarioDeviceObject.conditionUp()
                onPlusClickedSlow: scenarioDeviceObject.conditionUp()
                onPlusClickedFast: scenarioDeviceObject.conditionUpHeld()
            }
        }
    }
}
