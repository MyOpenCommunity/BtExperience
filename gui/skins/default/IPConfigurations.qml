import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 100
    signal ipConfigurationChanged(int ipConfiguration)

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
