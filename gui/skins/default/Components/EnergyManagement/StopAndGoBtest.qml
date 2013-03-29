import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: element

    Column {

        ControlSwitch {
            text: qsTr("Automatic Reclosing")
            pixelSize: 14
            onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
            status: !element.dataModel.autoReset
            enabled: element.dataModel.status === StopAndGo.Closed
        }

        ControlSwitch {
            text: qsTr("Test Circuit Breaker")
            pixelSize: 14
            onPressed: element.dataModel.autoTest = !element.dataModel.autoTest
            status: !element.dataModel.autoTest
            visible: element.dataModel.status === StopAndGo.Closed
        }

        ControlMinusPlus {
            title: qsTr("Test every")
            text: element.dataModel.autoTestFrequency === -1 ? "---" : qsTr("%1 days").arg(element.dataModel.autoTestFrequency)
            changeable: element.dataModel.autoTestFrequency !== -1
            onMinusClicked: element.dataModel.decreaseAutoTestFrequency()
            onPlusClicked: element.dataModel.increaseAutoTestFrequency()
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ButtonOkCancel {
            id: confirmationButtons

            onOkClicked: {
                element.dataModel.apply()
                element.closeColumn()
            }
            onCancelClicked: {
                element.dataModel.reset()
                element.closeColumn()
            }
        }
    }
}
