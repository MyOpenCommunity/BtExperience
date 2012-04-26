import QtQuick 1.1
import BtObjects 1.0


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
                        mapping.getComponent(dataModel.objectId),
                        "",
                        dataModel)
        }
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: modelList
    }
}

