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
                Component.onCompleted: {
                    daysModel.append({"day": qsTr("M"), "numDay": 1})
                    daysModel.append({"day": qsTr("T"), "numDay": 2})
                    daysModel.append({"day": qsTr("W"), "numDay": 3})
                    daysModel.append({"day": qsTr("T"), "numDay": 4})
                    daysModel.append({"day": qsTr("F"), "numDay": 5})
                    daysModel.append({"day": qsTr("S"), "numDay": 6})
                    daysModel.append({"day": qsTr("S"), "numDay": 7})
                }
            }

            ControlRadio {
                text: day
                onClicked: {
                    column.scenarioObject.setDayEnabled(numDay, !column.scenarioObject.isDayEnabled(numDay))
                    status = column.scenarioObject.isDayEnabled(numDay) // force the status update of the day
                }
                status: column.scenarioObject.isDayEnabled(numDay)
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
        itemObject: column.scenarioObject.timeCondition
        twoFields: true
    }
}
