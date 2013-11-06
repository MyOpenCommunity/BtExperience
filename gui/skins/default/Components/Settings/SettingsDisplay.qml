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
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    QtObject {
        id: privateProps

        function description(name) {
            if (name === qsTr("Brightness"))
                return global.screenState.normalBrightness + " %"

            return ""
        }
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: model.type === "column"
            description: privateProps.description(model.name)
            onDelegateTouched: {
                if (model.type === "column")
                    column.loadColumn(model.component, model.name)
                else {
                    resetSelection()
                    column.closeChild()
                    Stack.pushPage(model.component)
                }
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Brightness"), "component": brightness, "type": "column"})
            modelList.append({"name": qsTr("Calibration"), "component": "Calibration.qml", "type": "page"})
            modelList.append({"name": qsTr("Clean"), "component": "Clean.qml", "type": "page"})
        }
    }

    Component {
        id: brightness
        Brightness {}
    }
}
