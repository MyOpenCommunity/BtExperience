import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    property int monthIndex: -1

    QtObject {
        id: privateProps
        property real goal: dataModel.goals[monthIndex]
    }

    Column {
        ControlMinusPlus {
            onPlusClicked: {
                if (dataModel.energyType === EnergyData.Electricity)
                    privateProps.goal += .1
                else
                    privateProps.goal += 1
            }

            onMinusClicked: {
                if (privateProps.goal > 0) {
                    if (dataModel.energyType === EnergyData.Electricity)
                        privateProps.goal -= .1
                    else
                        privateProps.goal -= 1
                }
            }

            text: privateProps.goal.toFixed(dataModel.decimals) + " " + dataModel.cumulativeUnit
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
