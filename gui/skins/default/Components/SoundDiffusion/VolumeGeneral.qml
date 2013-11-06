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


Image {
    id: buttonSlider
    property alias description: label.text
    property string imagePath: "../../"

    source: imagePath + "images/common/bg_panel_212x100.svg"

    signal plusClicked
    signal minusClicked

    UbuntuMediumText {
        id: label
        font.pixelSize: 16
        color: "#444546"

        text: qsTr("volume")
        anchors {
            top: parent.top
            topMargin: buttonSlider.height * 10 / 100
            horizontalCenter: parent.horizontalCenter
        }
    }

    ButtonMinusPlus {
        id: buttons
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: buttonSlider.height * 10 / 100
        onPlusClicked: buttonSlider.plusClicked()
        onMinusClicked: buttonSlider.minusClicked()
    }
}
