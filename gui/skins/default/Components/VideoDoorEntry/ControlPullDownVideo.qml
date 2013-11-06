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


Item {
    id: control

    // we normally pass properties to the caller instead of objects inside other
    // objects to have reusable components but this control is very specific
    // to Video Door Entry system; in this case we prefer to pass the camera
    // object instead of passing 9 properties to the caller because they are really too many
    property variant camera

    signal opened
    signal closed

    ControlPullDown {
        menu: videoMenu
        onOpened: control.opened()
        onClosed: control.closed()
    }

    Component {
        id: videoMenu

        Column {
            ControlSlider {
                id: brightnessSlider
                percentage: control.camera === undefined ? 0 : control.camera.brightness
                description: qsTr("Brightness")
                onPlusClicked: if (control.camera !== undefined) control.camera.brightness += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.brightness -= 5
                onSliderClicked: control.camera.brightness = Math.round(desiredPercentage / 5) * 5
            }

            ControlSlider {
                id: contrastSlider
                percentage: control.camera === undefined ? 0 : control.camera.contrast
                description: qsTr("Contrast")
                onPlusClicked: if (control.camera !== undefined) control.camera.contrast += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.contrast -= 5
                onSliderClicked: control.camera.contrast = Math.round(desiredPercentage / 5) * 5
            }

            ControlSlider {
                id: colorSlider
                percentage: control.camera === undefined ? 0 : control.camera.color
                description: qsTr("Colour")
                onPlusClicked: if (control.camera !== undefined) control.camera.color += 5
                onMinusClicked: if (control.camera !== undefined) control.camera.color -= 5
                onSliderClicked: control.camera.color = Math.round(desiredPercentage / 5) * 5
            }
        }
    }
}
