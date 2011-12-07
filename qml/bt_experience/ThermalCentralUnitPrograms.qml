import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    signal programSelected(string programName)

    onChildLoaded: {
        if (child.programSelected)
            child.programSelected.connect(childProgramSelected)
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    function childProgramSelected(programName) {
        var model = itemList.model.getObject(itemList.currentIndex);

        element.programSelected(model.name + " " + programName)
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false
        property bool transparent: true

        delegate: MenuItemDelegate {
            hasChild: modelList.getComponentFile(model.objectId) !== null
            onClicked: {
                var component = modelList.getComponentFile(model.objectId)
                var item = itemList.model.getObject(model.index)

                if (component !== null)
                    element.loadElement(component, model.name, item)
                else {
                    element.closeChild()
                    element.programSelected(item.name)
                    item.apply()
                }
            }
        }

        model: element.dataModel.menuItemList

        ObjectModel {
            id: modelList
        }
    }
}
