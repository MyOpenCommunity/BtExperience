import QtQuick 1.1

MenuColumn {
    id: column
    width: 212
    height: 50
    MenuItem {
        name: dataModel.name
        status: dataModel.active === true ? 1 : 0
        hasChild: true
        onClicked: {
            column.columnClicked()
            column.loadColumn(
                        modelList.getComponent(dataModel.objectId),
                        "",
                        dataModel)
        }
    }

    ObjectModel {
        id: modelList
    }
}

