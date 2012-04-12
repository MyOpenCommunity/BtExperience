import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    signal modeChanged(int mode)

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator
        width: parent.width
        // TODO: is it ever possible to get the height of a MenuItemDelegate
        // without doing this??
        listHeight: 50 * paginator.elementsOnPage

        delegate: MenuItemDelegate {
            itemObject: modelData
            name: modelData
            status: modelData === dataModel.program ? 1 : 0
            onClicked: {
                dataModel.program = modelData
                modeChanged(dataModel.mode)
                element.closeElement()
            }
        }
        model: dataModel.programs
    }
}
