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


SvgImage {
    id: control

    property variant load

    source: "../../images/common/bg_on-off.svg"

    UbuntuLightText {
        text: qsTr("Instant consumption")
        color: "#323232"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: parent.top
            topMargin: parent.height / 100 * 15
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
    }

    UbuntuLightText {
        text: privateProps.getConsumptionText(load.consumption, load.currentUnit)
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 15
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
        elide: Text.ElideRight
        width: parent.width / 100 * 90
    }

    QtObject {
        id: privateProps

        function getConsumptionText(consumption, currentUnit) {
            if (consumption === 0)
                return "--"
            else
                return consumption + " " + currentUnit
        }
    }
}
