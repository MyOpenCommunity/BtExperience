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
import Components.Text 1.0


/**
  \ingroup Core

  \brief A component appearing above a MenuItem showing its title.
  */
SvgImage {
    id: title

    /** the MenuColumn component this MenuTitle refers to */
    property Item menuColumn: null
    /** type:string the text to be shown */
    property alias text: label.text

    source: "../images/menu_column/label_column-title.svg"
    opacity: menuColumn.opacity
    width: menuColumn.width

    Constants {
        id: constants
    }

    UbuntuMediumText {
        id: label

        color: "black"
        font.pixelSize: 14
        font.capitalization: Font.AllUppercase
        anchors {
            left: parent.left
            leftMargin: parent.width / 100 * 5
            right: parent.right
            rightMargin: parent.width / 100 * 5
            verticalCenter: parent.verticalCenter
        }
        elide: Text.ElideRight
    }

    Connections {
        id: conn
        target: title.menuColumn
        onDestroyed: title.destroy()
    }

    states: [
        State {
            name: "selected"
            when: menuColumn.isLastColumn
            PropertyChanges { target: title; source: "../images/menu_column/label_column-title_p.svg" }
            PropertyChanges { target: label; color: "white" }
        }
    ]
}

