import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: element

    Column {
        ControlSwitch {
            text: qsTr("Auto close")
            pixelSize: 14
            onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
            status: !element.dataModel.autoReset
        }
    }
}
