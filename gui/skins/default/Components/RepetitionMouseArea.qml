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

BeepingMouseArea {
    id: mouseArea

    property bool repetitionEnabled: false
    property bool repetitionTriggered: clickTimer.activations > 1
    property bool repetitionWithSlowFastClicks: false
    property int slowInterval: 350
    property int fastInterval: 100

    signal clickedSlow
    signal clickedFast

    onPressed: clickTimer.running = repetitionEnabled
    onReleased: clickTimer.running = false
    onVisibleChanged: {
        if (visible === false)
            clickTimer.running = false
    }

    Timer {
        id: clickTimer

        property int activations: 0

        onRunningChanged: {
            if (running) {
                activations = 1
                interval = slowInterval
            }
        }

        interval: slowInterval
        running: false
        repeat: true
        onTriggered: {
            if (activations++ === 5)
                interval = fastInterval
            if (repetitionWithSlowFastClicks) {
                if (interval === fastInterval)
                    mouseArea.clickedFast(mouseArea)
                else
                    mouseArea.clickedSlow(mouseArea)
            }
            else {
                mouseArea.clicked(mouseArea)
            }
        }
    }
}
