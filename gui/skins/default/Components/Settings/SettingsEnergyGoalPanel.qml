import QtQuick 1.1
import Components 1.0


MenuColumn {
    id: column
    property int monthIndex: -1

    QtObject {
        id: privateProps
        property int goal: dataModel.goals[monthIndex]
    }

    Column {
        ControlMinusPlus {
            onPlusClicked: {
                privateProps.goal += 1
            }

            onMinusClicked: {
                if (privateProps.goal > 0)
                    privateProps.goal -= 1
            }

            text: privateProps.goal + " " + dataModel.cumulativeUnit
            title: qsTr("consumption goal")
        }
        ButtonOkCancel {
            onOkClicked: {
                var goals = dataModel.goals
                goals[monthIndex] = privateProps.goal
                dataModel.goals = goals // because the EnergyData::setGoals has a list as argument we need this trick.
                column.closeColumn()
            }
            onCancelClicked: column.closeColumn()
        }
    }
}
