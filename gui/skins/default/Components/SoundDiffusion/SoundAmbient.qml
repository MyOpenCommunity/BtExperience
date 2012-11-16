import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    Component {
        id: sourceControl
        SourceControl {}
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
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

        PaginatorList {
            id: itemList

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
        range: paginator.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }
}
