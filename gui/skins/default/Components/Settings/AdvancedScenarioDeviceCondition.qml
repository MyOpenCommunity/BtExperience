import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

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
                   onClicked: scenarioDeviceObject.onOff = model.value
                }
            }
        }
    }


    Item { // a spacer
        height: 10
        width: line.width
    }

    Loader {
        sourceComponent: scenarioDeviceObject.range !== undefined ? controlSpinComponent : undefined
    }

    Component {
        id: controlSpinComponent
        Column {
            spacing: column.spacing
            UbuntuLightText {
                text: qsTr("Intensity")
                font.pixelSize: 14
                color: "white"
            }

            ControlSpin {
                text: scenarioDeviceObject.range
                onMinusClicked: scenarioDeviceObject.conditionDown()
                onPlusClicked: scenarioDeviceObject.conditionUp()
            }
        }
    }
}
