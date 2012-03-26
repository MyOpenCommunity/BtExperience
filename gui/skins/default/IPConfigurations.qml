import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fakeModel.count * 50

    signal ipConfigurationChanged(int ipConfiguration)

    ListModel {
        id: fakeModel
        ListElement {
            name: Network.Dhcp
            text: qsTr("dhcp")
        }
        ListElement {
            name: Network.Static
            text: qsTr("static IP address")
        }
    }

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        model: fakeModel
        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)
            hasChild: false
            name: itemObject.text
            onClicked: ipConfigurationChanged(itemObject.name)
        }
    }
}
