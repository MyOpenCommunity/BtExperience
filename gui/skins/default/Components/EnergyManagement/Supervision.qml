import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdSupervision }

    ObjectModel {
        id: listModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: loadDiagnosticModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            id: loadDiagnostic
            name: qsTr("load diagnostic")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            visible: loadDiagnosticModel.count > 0
            onTouched: {
                paginator.currentIndex = -1
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDiagnostic {}
            }
        }

        PaginatorList {
            id: paginator
            elementsOnPage: elementsOnMenuPage - 1
            currentIndex: -1
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: Script.description(itemObject)
                status: Script.status(itemObject)
                hasChild: Script.hasChild(itemObject)
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    element.loadColumn(mapping.getComponent(itemObject.objectId), name, itemObject)
                }
            }
            model: listModel
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1
    }

    BtObjectsMapping { id: mapping }
}
