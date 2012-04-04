import QtQuick 1.1
import Components 1.0

MenuElement {
    id: element
    width: 212
    height: sourceModel.count * 50

    signal sourceSelected(variant object)

    ListModel {
        id: sourceModel
        ListElement {
            name: "SD card"
            action: "browse"
        }
        ListElement {
            name: "usb 1"
            action: "browse"
        }
        ListElement {
            name: "usb 2"
            action: "browse"
        }
        ListElement {
            name: "LAN"
            action: "browse"
        }
        ListElement {
            name: "radio"
            action: ""
        }
        ListElement {
            name: "webradio"
            action: "saved IP radios"
        }
        ListElement {
            name: "MMT"
            action: "???"
        }
        ListElement {
            name: "AUX"
            action: "???"
        }
    }



    ListView {
        width: parent.width
        height: model.count * 50
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.get(index)
            name: model.name
            onClicked: element.sourceSelected(itemObject)
        }
        model: sourceModel
        interactive: false
    }
}
