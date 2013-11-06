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

    signal modalitySelected(int modality)

    height: 200
    width: 212

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: {
            for (var i = 0; i < modelList.count; ++i) {
                if (modelList.get(i).type === column.idx)
                    return i
            }
            return -1
        }
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            onDelegateTouched: {
                var clickedItem = modelList.get(index)
                column.modalitySelected(clickedItem.type)
                column.closeColumn()
            }
        }

        model: ListModel {
            id: modelList

            Component.onCompleted: {
                var l = [ThermalControlledProbe.Auto,
                         ThermalControlledProbe.Antifreeze,
                        ThermalControlledProbe.Manual,
                        ThermalControlledProbe.Off]
                for (var i = 0; i < l.length; i++)
                    append({"type": l[i], "name": pageObject.names.get('PROBE_STATUS', l[i])})
            }
        }

    }
}


