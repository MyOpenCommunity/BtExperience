import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fakeModel.count * 50

    signal ipConfigurationChanged(string ipConfiguration)

    ListModel {
        id: fakeModel
        ListElement {
            name: Network.Dhcp
        }
        ListElement {
            name: Network.Static
        }
    }

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        model: fakeModel
        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)
            active: element.animationRunning === false
            hasChild: false
            name: itemObject.name
            onClicked: ipConfigurationChanged(itemObject.name)
        }
    }
}
