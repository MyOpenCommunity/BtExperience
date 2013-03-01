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
                onMinusClickedSlow: scenarioDeviceObject.conditionDown()
                onMinusClickedFast: scenarioDeviceObject.conditionDown()
                onPlusClickedSlow: scenarioDeviceObject.conditionUp()
                onPlusClickedFast: scenarioDeviceObject.conditionUp()
            }
        }
    }
}
