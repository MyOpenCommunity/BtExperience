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
import BtObjects 1.0

MenuColumn {
    id: column

    width: 212 // needed for menu shadow

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        currentIndex: privateProps.selectedIndex
        delegate: MenuItemDelegate {
            name: model.name
            selectOnClick: false
            onDelegateTouched: {
                dataModel.mode = type
                column.closeColumn()
            }
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = dataModel.modes.values
                for (var i = 0; i < l.length; i++)
                {
                    append({"type": l[i], "name": pageObject.names.get('MODE', l[i])})
                    if (l[i] === dataModel.mode)
                        privateProps.selectedIndex = i
                }
                column.height = l.length * 50
            }
        }
    }

    QtObject {
        id: privateProps
        property int selectedIndex: -1
    }
}
