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

/**
  * A beeping mouse area.
  *
  * Component that implements a mouse area that beeps on press.
  * It manages clicks and pressAndHolds independently.
  * If pressAndHoldEnabled flag is not set the held signal is never emitted.
  * In such a case clicking and holding always generate only clicks.
  * If the flag is true, clicks are managed in the usual way, while
  * pressAndHolds generate held signals (and no click is emitted).
  */

import QtQuick 1.1
import BtExperience 1.0


MouseArea {
    id: control

    property bool pressAndHoldEnabled: false // set this to receive held signals

    signal clicked(variant mouse) // equivalent to MouseArea clicked
    signal held(variant mouse) // equivalent to MouseArea pressAndHold

    onPressed: {
        if (global.guiSettings.beep)
            global.beep()
    }
    onPressAndHold: {
        if (control.pressAndHoldEnabled) {
            global.debugTiming.logTiming("PressAndHold on icon")
            control.held(mouse)
        }
    }
    onReleased: {
        if (!control.pressAndHoldEnabled || !mouse.wasHeld) {
            // if pressAndHold is not enabled emits a click
            // if pressAndHold is enabled emits a click only if held is not managed
            global.debugTiming.logTiming("Clicked on icon")
            if (mouse.x >= 0 && mouse.x <= width &&
                mouse.y >= 0 && mouse.y <= height)
                control.clicked(mouse)
        }
    }
}
