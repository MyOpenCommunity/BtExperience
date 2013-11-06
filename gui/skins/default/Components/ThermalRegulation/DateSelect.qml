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

MenuColumn {
    id: column

    property bool dateVisible: true
    property alias source: background.source
    property alias dateText: labelDate.text
    property alias timeText: labelTime.text

    height: background.height
    width: background.width

    SvgImage {
        id: background
        source: "../../images/termo/comando_data-ora/bg_comando_data-ora.svg"

        UbuntuLightText {
            id: labelDate
            visible: column.dateVisible
            color: "black"
            text: qsTr("until date")
            font.pixelSize: 15
            elide: Text.ElideRight
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 7
                right: parent.right
                rightMargin: 7
            }
        }

        ControlDateTime {
            id: controlDate
            visible: column.dateVisible
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelDate.bottom
                topMargin: 7
            }
            itemObject: column.dateVisible ? dataModel : undefined
            separator: "/"
            mode: 1
        }

        UbuntuLightText {
            id: labelTime
            color: "black"
            text: qsTr("until time")
            font.pixelSize: 15
            elide: Text.ElideRight
            anchors {
                top: column.dateVisible ? controlDate.bottom : parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 7
                right: parent.right
                rightMargin: 7
            }
        }

        ControlDateTime {
            id: controlTime
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelTime.bottom
                topMargin: 7
            }
            itemObject: dataModel
            mode: 0
            twoFields: true
        }
    }
}
