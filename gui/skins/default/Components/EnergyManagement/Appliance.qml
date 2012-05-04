import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height
    property int choice: 0

    Column {
        id: column
        ControlUpDown {
            id: enabler
            title: qsTr("control")
            text: qsTr("disable")
        }
        ButtonOkCancel {
            onOkClicked: {
                if (element.choice === 0) {
                    pageObject.installPopup(disableLoadPopup)
                }
            }
            Component {
                id: disableLoadPopup
                DisableLoadPopup {}
            }
        }
    }
}
