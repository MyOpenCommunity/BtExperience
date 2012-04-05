import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 250
    signal timeChanged(string value, int auto, int format)

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdGuiSettings}]
    }
    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 400

        Image {
            width: 212
            height: 50
            source: "images/common/btn_menu.png"
            Text {
                id: time
                // TODO must be editable
                text: privateProps.model.time
                anchors.fill: parent
            }
        }

        ControlChoices {
            id: auto
            description: qsTr("automatic update")
            choice: pageObject.names.get('AUTO_UPDATE', currentIndex)
            property bool currentIndex: privateProps.model.autoUpdate
            onPlusClicked: {
                if (currentIndex < 1) {
                    choice = pageObject.names.get('AUTO_UPDATE', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex >= 0) {
                    choice = pageObject.names.get('AUTO_UPDATE', --currentIndex)
                }
            }
        }

        ControlChoices {
            id: format
            description: qsTr("format")
            choice: pageObject.names.get('FORMAT', currentIndex)
            property int currentIndex: privateProps.model.format
            onPlusClicked: {
                if (currentIndex < 1) {
                    choice = pageObject.names.get('FORMAT', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex >= 0) {
                    choice = pageObject.names.get('FORMAT', --currentIndex)
                }
            }
        }
        ButtonOkCancel {
            onOkClicked: {
                element.timeChanged(time.text, auto.currentIndex, format.currentIndex)
            }
        }
    }
}
