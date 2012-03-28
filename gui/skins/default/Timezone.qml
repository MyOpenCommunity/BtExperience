import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 200
    signal timezoneChanged(int gmtOffset)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: timezoneChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                // TODO maybe we need some enum
                var l = [-2,
                         -1,
                         0,
                         1,
                         2,
                        ]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('TIMEZONE', l[i])
                           })
            }
        }
    }
}
