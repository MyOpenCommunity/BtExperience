import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    signal modeChanged(int mode)

    width: 212 // needed for menu shadow

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: modelData
            name: modelData
            status: -1
            onClicked: {
                dataModel.program = modelData
                modeChanged(dataModel.mode)
                column.closeColumn()
            }
        }
        model: dataModel.programs
        Component.onCompleted: {
            paginator.listHeight = column.height = 50 * model.length
        }
    }
}
