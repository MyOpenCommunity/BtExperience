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

    property variant platform

    width: 212
    height: Math.max(1, 50 * ipConfigurationView.count)

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        interactive: false
        currentIndex: -1
        delegate: MenuItemDelegate {
            name: pageObject.names.get('CONFIG', modelData)
            isSelected: platform.lanConfig === modelData
            onDelegateTouched: {
                platform.lanConfig = modelData
                column.closeColumn()
            }
        }
        model: [PlatformSettings.Dhcp,
                PlatformSettings.Static]
    }
}
