import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: paginator.height
    signal timezoneChanged(int gmtOffset)

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

        ControlChoices {
            id: tmz
            description: qsTr("time zone")
            choice: pageObject.names.get('TIMEZONE', currentIndex)
            property int currentIndex: privateProps.model.timezone
            onPlusClicked: {
                if (currentIndex < 2) {
                    choice = pageObject.names.get('TIMEZONE', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex > -2) {
                    choice = pageObject.names.get('TIMEZONE', --currentIndex)
                }
            }
        }
        ButtonOkCancel {
            onOkClicked: {
                element.timezoneChanged(tmz.currentIndex)
            }
        }
    }
}
