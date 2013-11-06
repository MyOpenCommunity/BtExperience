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
import BtExperience 1.0
import Components.Text 1.0

SvgImage {
    id: button

    property string text: ""
    property int textVerticalOffset: 45
    property url icon: ""
    property url iconPressed: ""
    property url sourcePressed: ""
    property bool enabled: true

    signal touched

    BeepingMouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: touchTimer.restart()

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: button.touched()
        }
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: button.enabled === false
        MouseArea { anchors.fill: parent }
    }

    SvgImage {
        id: imageIcon
        source: button.icon
        anchors.centerIn: parent
    }

    UbuntuMediumText {
        id: text
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" :
                                                              "#FFFFFF"
        text: button.text
        anchors.centerIn: parent
        anchors.verticalCenterOffset: textVerticalOffset
        font.pixelSize: 15
    }

    states: State {
        name: "pressed"
        when: mouseArea.pressed

        PropertyChanges { target: button; source: sourcePressed; }
        PropertyChanges {
            target: text
            color: homeProperties.skin === HomeProperties.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }
    }
}
