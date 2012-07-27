import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
    id: column
    width: line.width
    spacing: 10
    property variant scenarioObject

    UbuntuMediumText {
        text: qsTr("activation")
        font.pixelSize: 18
        color: "white"
    }

    SvgImage {
        id: line
        source: "../../images/common/linea.svg"
    }

    UbuntuLightText {
        text: qsTr("days")
        font.pixelSize: 14
        color: "white"
    }

    Row {
        spacing: 13
        height: childrenRect.height

        Repeater {
            model: ListModel {
                id: daysModel
                ListElement { day: "M" }
                ListElement { day: "T" }
                ListElement { day: "W" }
                ListElement { day: "T" }
                ListElement { day: "F" }
                ListElement { day: "S" }
                ListElement { day: "S" }
            }

            ControlRadio {
                text: day
                onClicked: status = !status
            }
        }
    }

    Item { // a spacer
        height: 10
        width: line.width
    }

    UbuntuLightText {
        text: qsTr("time")
        font.pixelSize: 14
        color: "white"
    }


    ControlDateTime {
        itemObject: column.scenarioObject
        twoFields: true
    }
}
