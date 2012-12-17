import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    Column {
        MenuItem {
            name: qsTr("Change password")
            onClicked: {
                console.log("clicked on change password")
                Stack.pushPage("ChangePassword.qml")
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: global.passwordEnabled

            delegate: MenuItemDelegate {
                name: model.name
                onClicked: global.passwordEnabled = value
            }

            model: modelList
            onCurrentPageChanged: column.closeColumn()
        }
    }

    ListModel {
        id: modelList
    }

    Component.onCompleted: {
        modelList.append({"value": false, "name": pageObject.names.get('PASSWORD', false)})
        modelList.append({"value": true, "name": pageObject.names.get('PASSWORD', true)})
        paginator.currentIndex = global.passwordEnabled
    }
}
