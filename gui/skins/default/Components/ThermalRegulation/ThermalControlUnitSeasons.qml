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


MenuColumn {
    id: column

    property int idx: -1

    signal seasonSelected(int season)

    height: 100
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: column.idx
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            onDelegateTouched: {
                var clickedItem = modelList.get(index)
                column.seasonSelected(clickedItem.type)
                column.closeColumn()
            }
        }

        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [ThermalControlUnit.Summer,
                         ThermalControlUnit.Winter]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('SEASON', l[i])})
                // restores the right value for the itemList currentIndex property
                // because the append function changes it
                itemList.currentIndex = column.idx
            }
        }
    }
}

