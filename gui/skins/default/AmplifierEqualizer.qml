import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: listModel.count * 50

    ListModel {
        id: listModel

        ListElement {
            name: "off"
        }
        ListElement {
            name: "pop"
        }
        ListElement {
            name: "rock"
        }
        ListElement {
            name: "classical"
        }
    }



    ListView {
        height: listModel.count * 50
        delegate: MenuItem {
            active: element.animationRunning === false
            name: model.name
            onClicked: element.closeElement()
        }

        model: listModel
    }
}
