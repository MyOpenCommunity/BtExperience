import QtQuick 1.1
import BtObjects 1.0


MenuColumn {
    id: column

    signal pressed

    MenuItem {
        id: theMenu

        name: dataModel.name
        status: dataModel.active === true ? 1 : 0
        hasChild: true

        // We are assuming that items in rooms are always editable
        editable: true
        onEditCompleted: dataModel.name = name

        onClicked: {
            column.columnClicked()
            column.loadColumn(mapping.getComponent(dataModel.objectId), "", dataModel)
        }
        onPressed: column.pressed()
    }

    BtObjectsMapping { id: mapping }

    /* simply forwarding to the menu builtin focusLost function */
    function focusLost() {
        theMenu.focusLost()
    }
}

