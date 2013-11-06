/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
            name: qsTr("Add Alarm clock")
            isSelected: privateProps.currentIndex === 1

            onTouched: {
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
                onDelegateTouched: {
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
