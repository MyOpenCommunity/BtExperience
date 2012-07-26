import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element

    Column {
        ControlMinusPlus {
            title: qsTr("force load")
            text: qsTr("180 minutes")
        }

        ButtonOkCancel { }
    }
}
