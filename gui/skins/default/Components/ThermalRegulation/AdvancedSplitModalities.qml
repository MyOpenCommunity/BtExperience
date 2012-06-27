import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212
    height: 300

    signal modeChanged(int mode)

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
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('MODE', l[i])
                           })
            }
        }
    }
}
