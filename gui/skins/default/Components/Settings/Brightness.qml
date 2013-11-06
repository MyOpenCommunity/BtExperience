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
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    ControlSlider {
        id: brightness

        percentage: global.screenState.normalBrightness
        description: qsTr("brightness")
        onPlusClicked: global.screenState.normalBrightness += 5
        onMinusClicked: global.screenState.normalBrightness -= 5
        onSliderClicked: global.screenState.normalBrightness = Math.round(desiredPercentage / 5) * 5
    }
}
