import QtQuick 1.1
import "Stack.js" as Stack

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212


    ListView {
        id: itemList
        anchors.fill: parent

        currentIndex: -1

        delegate: MenuItemDelegate {
            active: true
            name: model.name
            hasChild: false
            selectOnClick: true
            onClicked: {
                Stack.container.animation.source = model.componentFile
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "fade"
            componentFile: "FadeAnimation.qml"
        }

        ListElement {
            name: "slide"
            componentFile: "SlideAnimation.qml"
        }
    }
}
