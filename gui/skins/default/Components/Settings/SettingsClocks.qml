import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/EventManager.js" as EventManager


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdAlarmClock}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
        paginator.currentIndex = -1
    }

    Column {
        MenuItem {
            name: qsTr("Add Clock")
            isSelected: privateProps.currentIndex === 1

            onClicked: {
                paginator.currentIndex = -1
                privateProps.currentIndex = 1
                objectModel.append(myHomeModels.createAlarmClock())
            }
        }

        PaginatorList {
            id: paginator

            model: objectModel
            onCurrentPageChanged: column.closeChild()

            delegate: MenuItemDelegate {
                itemObject: objectModel.getObject(index)
                hasChild: true
                name: itemObject.description
                onClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(controlAlarmClockComponent, itemObject.description, itemObject)
                }
            }
        }
    }

    Component {
        id: controlAlarmClockComponent
        ControlAlarmClock {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
