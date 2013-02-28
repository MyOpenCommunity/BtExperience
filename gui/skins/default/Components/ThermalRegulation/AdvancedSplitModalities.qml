import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    width: 212 // needed for menu shadow

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        currentIndex: privateProps.selectedIndex
        delegate: MenuItemDelegate {
            name: model.name
            selectOnClick: false
            onDelegateTouched: {
                dataModel.mode = type
                column.closeColumn()
            }
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = dataModel.modes.values
                for (var i = 0; i < l.length; i++)
                {
                    append({"type": l[i], "name": pageObject.names.get('MODE', l[i])})
                    if (l[i] === dataModel.mode)
                        privateProps.selectedIndex = i
                }
                column.height = l.length * 50
            }
        }
    }

    QtObject {
        id: privateProps
        property int selectedIndex: -1
    }
}
