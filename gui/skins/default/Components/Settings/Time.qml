import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    property string imagesPath: "../../images/"

    signal timeChanged(variant value, int auto, int format)

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdHardwareSettings}]
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
            source: imagesPath + "common/btn_menu.png"
            UbuntuLightText {
                id: time
                // TODO must be editable
                text: privateProps.model.time
                anchors.fill: parent
            }
        }

        ControlChoices {
            id: format
            description: qsTr("format")
            choice: pageObject.names.get('FORMAT', currentIndex)
            property int currentIndex: global.guiSettings.format
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
                column.timeChanged(time.text, auto.currentIndex, format.currentIndex)
            }
        }
    }
}
