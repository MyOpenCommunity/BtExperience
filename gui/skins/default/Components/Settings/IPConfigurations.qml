import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    signal ipConfigurationChanged(int ipConfiguration)

    width: 212
    height: Math.max(1, 50 * ipConfigurationView.count)

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: ipConfigurationChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [PlatformSettings.Dhcp,
                         PlatformSettings.Static]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('CONFIG', l[i])})
            }
        }
    }
}
