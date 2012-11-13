import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    property real rateValue: column.dataModel.rate

    Column {
        ControlMinusPlus {
            id: temp
            title: column.dataModel.name
            text: column.rateValue.toFixed(column.dataModel.displayDecimals) + " " + column.dataModel.currencySymbol + "/" + column.dataModel.measureUnit
            onPlusClicked: column.rateValue += column.dataModel.rateDelta
            onMinusClicked: {
                if (column.rateValue - column.dataModel.rateDelta > 0)
                    column.rateValue -= column.dataModel.rateDelta
            }
        }

        ButtonOkCancel {
            onOkClicked: {
                column.dataModel.rate = column.rateValue
                column.closeColumn()
            }
            onCancelClicked: {
                column.closeColumn()
            }
        }
        }
}

