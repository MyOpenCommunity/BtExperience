import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: equalizerList.height

    ListView {
        id: equalizerList
        height: objectModel.size * 50
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            name: itemObject.name
            selectOnClick: true
            onDelegateClicked: element.dataModel.preset = index
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        source: element.dataModel.presets
    }
}
