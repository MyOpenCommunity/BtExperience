import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 100
    signal networkChanged(int state)

    ListView {
        id: networkStateView
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: networkChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [PlatformSettings.Disabled,
                         PlatformSettings.Enabled]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('STATE', l[i])})
            }
        }
    }
}
