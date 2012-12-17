import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    PaginatorList {
        id: list
        currentIndex: global.passwordEnabled

        delegate: MenuItemDelegate {
            name: model.name
            onClicked: global.passwordEnabled = value
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
    }

    Component.onCompleted: {
        modelList.append({"value": false, "name": pageObject.names.get('PASSWORD', false)})
        modelList.append({"value": true, "name": pageObject.names.get('PASSWORD', true)})
        list.currentIndex = global.passwordEnabled
    }
}
