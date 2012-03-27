import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    // dimensions
    width: 212
    height: paginator.height

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatform}]
    }
    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 250

        Column {
            Rectangle {
                width: 212
                height: 100
                color: "#00e6ff"
            }

            // ip configuration menu item (currentIndex === 2)
            MenuItem {
                id: typeItem
                name: qsTr("type")
                description: qsTr("none")
                hasChild: true
                state: privateProps.currentIndex === 2 ? "selected" : ""
                onClicked: {
                    if (privateProps.currentIndex !== 2)
                        privateProps.currentIndex = 2
                    element.loadElement("IPConfigurations.qml", name)
                }
            }

//            ControlChoices {
//                description: qsTr("turn off display")
//                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', 5)
//                property int currentIndex: 5
//                onPlusClicked: {
//                    if (currentIndex < 9) {
//                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', ++currentIndex)
//                    }
//                }
//                onMinusClicked: {
//                    if (currentIndex >= 0) {
//                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', --currentIndex)
//                    }
//                }
//            }
        }
    }
}
