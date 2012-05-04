import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height

    Column {
        id: column
        ControlCall {
            name: qsTr("FORCE LOAD ON")
            description: ""
            callImage: ""
            state: "command"
        }
    }
}
