import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: fakeModel.count * 50

    signal ipConfigurationChanged(string ipConfiguration)

    ListModel {
        id: fakeModel
        ListElement {
            name: "DHCP"
        }
        ListElement {
            name: "static IP address"
        }
    }

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        model: fakeModel
        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)
            hasChild: false
            name: itemObject.name
            onClicked: ipConfigurationChanged(itemObject.name)
        }
    }
}
