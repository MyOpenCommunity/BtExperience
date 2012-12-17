import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    property alias amplifierNumber: itemList.elementsOnPage
    property alias showSourceControl: sourceLoader.visible

    Component {
        id: sourceControl
        SourceControl {}
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
    }

    ObjectModel {
        id: ambientModel
        filters: [{objectId: ObjectInterface.IdAmbientAmplifier}]
        containers: [column.dataModel.uii]
    }

    Column {
        MenuItem {
            id: sourceLoader
            property variant itemObject: column.dataModel.currentSource
            isSelected: privateProps.currentIndex === 1
            name: qsTr("source")
            description: itemObject === undefined ? "" : itemObject.name
            hasChild: true
            onClicked: {
                privateProps.currentIndex = 1
                itemList.currentIndex = -1
                column.loadColumn(sourceControl, qsTr("source"), column.dataModel)
            }
        }

        Column {
            id: ambientControl
            visible: ambientModel.count > 0
            property variant itemObject: ambientModel.getObject(0)

            VolumeGeneral {
                onMinusClicked: ambientControl.itemObject.volumeDown()
                onPlusClicked: ambientControl.itemObject.volumeUp()
            }

            ControlOnOff {
                onClicked: ambientControl.itemObject.setActive(newStatus)
            }
        }

        PaginatorList {
            id: itemList

            elementsOnPage: 4
            delegate: MenuItemDelegate {
                editable: true
                itemObject: objectModel.getObject(index)

                status: Script.status(itemObject)
                hasChild: Script.hasChild(itemObject)
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject);
                }
            }

            model: objectModel
            onCurrentPageChanged: column.closeChild()
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGroup},
            {objectId: ObjectInterface.IdSoundAmplifier},
            {objectId: ObjectInterface.IdPowerAmplifier}
        ]
        containers: [column.dataModel.uii]
        range: itemList.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }
}
