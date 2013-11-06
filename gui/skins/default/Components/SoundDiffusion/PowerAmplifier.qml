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
import Components 1.0

MenuColumn {
    id: column

    Component {
        id: amplifierSettings
        AmplifierSettings {}
    }

    onChildDestroyed: amplifierSettingsMenu.state = ""

    ControlOnOff {
        id: buttonOnOff
        status: column.dataModel.active
        onClicked: column.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: column.dataModel.volume
        sliderEnabled: column.dataModel.active
        onMinusClicked: column.dataModel.volumeDown()
        onPlusClicked: column.dataModel.volumeUp()
        onSliderClicked: column.dataModel.volume = desiredPercentage
    }

    MenuItem {
        id: amplifierSettingsMenu
        anchors.top: volumeSlider.bottom
        name: qsTr("settings")
        hasChild: true
        onTouched: {
            if (!isSelected)
                isSelected = true
            column.loadColumn(amplifierSettings, qsTr("settings"), column.dataModel)
        }
    }
}
