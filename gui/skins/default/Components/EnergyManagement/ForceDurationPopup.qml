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


Column {
    id: control

    property variant loadWithCU

    signal closePopup

    ControlMinusPlus {
        title: qsTr("Force the load")
        text: format(loadWithCU.forceDuration)
        fastClickInterval: 50
        onMinusClicked: loadWithCU.decreaseForceDuration()
        onPlusClicked: loadWithCU.increaseForceDuration()
        Component.onCompleted: loadWithCU.resetForceDuration()

        function format(minutes) {
            var h = Math.floor(minutes / 60)
            if (h < 10)
                h = "0" + h
            var m = minutes % 60
            if (m < 10)
                m = "0" + m
            return qsTr("Time") + ": " + h + ":" + m
        }
    }

    SvgImage {
        source: "../../images/common/panel_212x50.svg"

        ButtonThreeStates {
            id: buttonCancel

            defaultImage: "../../images/common/btn_99x35.svg"
            pressedImage: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            text: qsTr("cancel")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 15
            onClicked: control.closePopup()
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 7
            }
        }

        ButtonThreeStates {
            id: buttonForce

            defaultImage: "../../images/common/btn_99x35.svg"
            pressedImage: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            text: qsTr("force")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 15
            onClicked: {
                loadWithCU.forceOn(loadWithCU.forceDuration)
                control.closePopup()
            }
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 7
            }
        }
    }
}
