import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/EventManager.js" as EventManager
import "../../js/MenuItem.js" as MenuItem
import "../../js/Stack.js" as Stack


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
                var a = myHomeModels.createAlarmClock()
                objectModel.append(a)
                Stack.pushPage("AlarmClockDateTimePage.qml", {alarmClock: a, isNewAlarm: true})
            }
        }

        PaginatorList {
            id: paginator

            model: objectModel
            onCurrentPageChanged: column.closeChild()
            elementsOnPage: elementsOnMenuPage - 1

            delegate: MenuItemDelegate {
                itemObject: objectModel.getObject(index)
                hasChild: true
                name: itemObject ? itemObject.description : ""
                description: itemObject ? MenuItem.description(itemObject) : ""
                status: itemObject ? MenuItem.status(itemObject) : -1
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
