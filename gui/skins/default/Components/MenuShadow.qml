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


/**
  \ingroup Core

  \brief A shadow sorrounding a menu.
  */
BorderImage {
    id: item

    /** type:Object the MenuColumn this shadow refers to */
    property alias menuColumn: conn.target

    source: "../images/common/ombra1elemento.png"
    border { left: 30; top: 30; right: 30; bottom: 30; }
    anchors { leftMargin: -25; topMargin: -25; rightMargin: -25; bottomMargin: -25 }
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch

    Connections {
        id: conn
        target: null
        onDestroyed: item.destroy()
    }
}

