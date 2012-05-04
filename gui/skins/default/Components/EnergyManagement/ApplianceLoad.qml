import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height
    property int choice: 1

    Column {
        id: column
        ControlUpDown {
            id: enabler
            title: qsTr("control")
            text: qsTr("enabled")
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

        MenuItem {
            id: loadDetail
            name: qsTr("load detail")
            state: privateProps.currentIndex === 1 ? "selected" : ""
            hasChild: true
            onClicked: {
                listView.currentIndex = -1
                privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDetail {}
            }
        }
    }
}
