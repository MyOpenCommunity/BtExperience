import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: fakeModel.count * 50

    signal modalityChanged(string modality)

    ListModel {
        id: fakeModel
        ListElement {
            name: "auto"
        }
        ListElement {
            name: "rinfresca"
        }
        ListElement {
            name: "riscalda"
        }
        ListElement {
            name: "deumidificatore"
        }
        ListElement {
            name: "fancoil"
        }
        ListElement {
            name: "off"
        }
    }

    ListView {
        id: modalityView
        anchors.fill: parent
        model: fakeModel
        delegate: MenuItemDelegate {
            itemObject: fakeModel.get(index)
            active: element.animationRunning === false
            hasChild: false
            name: itemObject.name
            onClicked: modalityChanged(itemObject.name)
        }
    }
}
