import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    signal modeChanged(int mode)

    width: 212 // needed for menu shadow

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: {
                modeChanged(model.type)
                column.closeColumn()
            }
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = dataModel.modes.values
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('MODE', l[i])})
                column.height = l.length * 50
            }
        }
    }
}
