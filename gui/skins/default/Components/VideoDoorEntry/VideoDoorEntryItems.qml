import QtQuick 1.1
import Components 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: element
    height: 150
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                element.loadElement(clickedItem.componentFile, clickedItem.name)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: 'CCTV'
                componentFile: "Components/VideoDoorEntry/CCTV.qml"
            }
            ListElement {
                name: 'intercom'
                componentFile: "Components/VideoDoorEntry/InterCom.qml"
            }
            ListElement {
                name: 'pager'
                componentFile: "Components/VideoDoorEntry/Pager.qml"
            }
        }

    }
}



