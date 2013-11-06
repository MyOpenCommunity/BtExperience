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
import Components.Text 1.0
import "../js/EventManager.js" as EventManager
import "../js/navigation.js" as Navigation


Item {
    id: control

    Rectangle {
        id: bottomBg
        opacity: 0.8
        color: "#5A5A5A"
        anchors.fill: parent
    }

    UbuntuLightText {
        id: label
        text: qsTr("Save scenario recording?")
        font.pixelSize: 14
        color: "white"
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: okButton.left
            rightMargin: bottomBg.width / 100 * 1.00
        }
    }

    ButtonThreeStates {
        id: okButton

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        text: qsTr("OK")
        font.pixelSize: 14
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: bottomBg.right
            rightMargin: bottomBg.width / 100 * 1.00
        }
        onClicked: {
            if (EventManager.eventManager.scenarioRecording)
                EventManager.eventManager.scenarioRecorder.stopProgramming()
            else
                console.log("Trying to finalize a scenario recording, but no scenario module is in edit mode")
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 400 }
    }
}
