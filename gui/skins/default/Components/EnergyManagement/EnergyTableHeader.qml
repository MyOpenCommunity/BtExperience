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


Column {
    id: tableHeader
    property string label
    property string unitMeasure

    Row {
        id: row
        spacing: 5
        height: 28

        Rectangle {
            color: "#e6e6e6"
            width: 95
            height: parent.height
            UbuntuLightText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pixelSize: 14
                text: tableHeader.label
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            color: "#e6e6e6"
            width: 95
            height: parent.height
            UbuntuLightText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pixelSize: 14
                text: tableHeader.unitMeasure
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    Item {
        height: 10
        width: row.width
    }
}

