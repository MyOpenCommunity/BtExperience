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
import Components.Text 1.0


Row {
    id: tableRow

    property string index
    property string value
    property color valueColor: "white"
    property alias indexHorizontalAlignment: indexText.horizontalAlignment

    spacing: 5
    height: 24

    Item {
        width: 95
        height: parent.height
        UbuntuLightText {
            id: indexText

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
            }
            text: tableRow.index
            font.pixelSize: 14
            color: "white"
        }
    }

    Item {
        width: 95
        height: parent.height
        UbuntuLightText {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
            }
            text: tableRow.value
            font.pixelSize: 14
            color: tableRow.valueColor
            horizontalAlignment: Text.AlignRight
        }
    }
}
