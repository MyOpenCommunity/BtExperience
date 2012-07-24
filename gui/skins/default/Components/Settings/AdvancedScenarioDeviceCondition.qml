import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
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
        text: qsTr("device description")
        font.pixelSize: 14
        color: "white"
    }

    Row {
        spacing: 13
        height: childrenRect.height

        Repeater {
            model: ListModel {
                ListElement { status: "ON" }
                ListElement { status: "OFF" }
            }

            ControlRadio {
                text: model.status
                onClicked: status = !status
            }
        }
    }

    Item { // a spacer
        height: 10
        width: line.width
    }

    UbuntuLightText {
        text: qsTr("intensity")
        font.pixelSize: 14
        color: "white"
    }

    ControlSpin {
        text: "80%"
        onMinusClicked: {

        }

        onPlusClicked: {

        }

    }
}
