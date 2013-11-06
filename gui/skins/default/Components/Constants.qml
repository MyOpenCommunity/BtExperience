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

QtObject {
    // time needed for a new column (MenuColumn) to show up
    property int elementTransitionDuration: 400
    // time needed to show the line above the MenuColumn
    property int lineTransitionDuration: elementTransitionDuration / 2
    // time needed to show an alert popup (termo, antintrusion ...)
    property int alertTransitionDuration: 200

    property int navbarTopMargin: 33
}
