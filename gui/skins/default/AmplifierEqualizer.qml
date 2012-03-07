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

    Component {
        id: viewDelegate
        MenuItem {
            id: itemDelegate
            active: element.animationRunning === false
            name: model.name
            onClicked: equalizerList.currentIndex = index

            states: State {
                name: "delegateselected"
                extend: "selected"
                when: itemDelegate.ListView.isCurrentItem
            }
        }
    }


    ListView {
        id: equalizerList
        height: listModel.count * 50
        delegate: viewDelegate

        model: listModel
    }
}
