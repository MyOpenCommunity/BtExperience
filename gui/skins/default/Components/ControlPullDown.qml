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
  * A control to implement a pull down menu.
  * It has two states:
  *     - up: the down arrow is visible
  *     - down: the up arrow is visible
  * It has a loader where to load components (the menu, tipically).
  */

import QtQuick 1.1
import Components.VideoDoorEntry 1.0


Item {
    id: control

    property alias text: theButton.text
    property variant menu
    property alias menuAnchors: menuLoader.anchors

    signal opened
    signal closed

    onStateChanged: control.state === "up" ? control.closed() : control.opened()

    ButtonTextImageThreeStates {
        id: theButton

        text: qsTr("Video settings")
        textColor: "black"
        onPressed: control.state = (control.state === "up") ? "down" : "up"
        defaultImageBg: "../images/common/btn_impostazioni.svg"
        pressedImageBg: "../images/common/btn_impostazioni_P.svg"
        defaultImage: "../images/common/ico_apri_impostazioni.svg"
        pressedImage: "../images/common/ico_apri_impostazioni_P.svg"
        shadowImage: "../images/common/ombra_btn_impostazioni.svg"
        imageAnchors.rightMargin: 7
        anchors.top: parent.top
    }

    Loader {
        id: menuLoader

        anchors.top: theButton.bottom
    }

    state: "up"

    states: [
        State {
            name: "up"
            extend: ""
        },
        State {
            name: "down"
            PropertyChanges {
                target: theButton
                defaultImage: "../images/common/ico_chiudi_impostazioni.svg"
                pressedImage: "../images/common/ico_chiudi_impostazioni.svg"
            }
            PropertyChanges {
                target: menuLoader
                sourceComponent: menu
            }
        }
    ]
}
