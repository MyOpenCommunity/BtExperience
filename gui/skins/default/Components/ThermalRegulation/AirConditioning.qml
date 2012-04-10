import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    onChildDestroyed: paginator.currentIndex = -1

    onChildLoaded: {
        if (child.basicSplitChanged)
            child.basicSplitChanged.connect(basicSplitChanged)
    }

    function basicSplitChanged(value) {
        objectModel.getObject(paginator.currentIndex).enable = value
    }

    PaginatorList {
        id: paginator
        width: parent.width
        // TODO: is it ever possible to get the height of a MenuItemDelegate
        // without doing this??
        listHeight: 50 * paginator.elementsOnPage

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)

            //status: itemObject.active === true ? 1 : 0
            hasChild: true
            onClicked: {
                element.loadElement(objectModel.getComponentFile(itemObject.objectId),
                                    itemObject.name,
                                    objectModel.getObject(model.index))
            }
        }
        model: objectModel
    }

    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario}
        ]
    }
}
