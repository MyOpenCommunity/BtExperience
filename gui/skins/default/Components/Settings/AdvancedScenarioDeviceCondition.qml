import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
    id: column
    property variant scenarioObject

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
        text: qsTr("device description")
        font.pixelSize: 14
        color: "white"
    }

    Loader {
        sourceComponent: scenarioObject.onOff !== undefined ? controlOnOff : undefined
    }

    Component {
        id: controlOnOff
        Row {
            spacing: 13
            height: childrenRect.height

            Repeater {
                model: ListModel {
                    ListElement { text: "ON"; value: true }
                    ListElement { text: "OFF"; value: false }
                }

                ControlRadio {
                   status: scenarioObject.onOff === model.value
                   text: model.text
                   onClicked: scenarioObject.onOff = model.value
                }
            }
        }
    }


    Item { // a spacer
        height: 10
        width: line.width
    }

    UbuntuLightText {
        visible: scenarioObject.range !== undefined
        text: scenarioObject.description
        font.pixelSize: 14
        color: "white"
    }

    ControlSpin {
        visible: scenarioObject.range !== undefined
        text: scenarioObject.range
        onMinusClicked: scenarioObject.conditionDown()
        onPlusClicked: scenarioObject.conditionUp()
    }
}
