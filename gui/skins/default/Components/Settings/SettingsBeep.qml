import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: global.guiSettings.beep = type == 0
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [0,
                         1,
                        ]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('BEEP', l[i])
                           })
            }
        }
    }
}
