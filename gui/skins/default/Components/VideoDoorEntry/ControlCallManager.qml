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
  * A control that implements buttons to manage a call.
  * No text inside this control. There is an advanced version of this control
  * with text and image.
  */

import QtQuick 1.1
import Components 1.0


SvgImage {
    id: control

    signal leftClicked
    signal rightClicked

    source: "../../images/common/bg_btn_rispondi_L.svg"

    ButtonImageThreeStates {
        id: buttonLeft

        defaultImageBg: "../../images/common/btn_rispondi.svg"
        pressedImageBg: "../../images/common/btn_rispondi_P.svg"
        shadowImage: "../../images/common/ombra_btn_rispondi.svg"
        defaultImage: "../../images/common/ico_rispondi.svg"
        pressedImage: "../../images/common/ico_rispondi_P.svg"
        onPressed: control.leftClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 9
            left: parent.left
            leftMargin: 7
        }
    }

    ButtonImageThreeStates {
        id: buttonRight

        defaultImageBg: "../../images/common/btn_rifiuta.svg"
        pressedImageBg: "../../images/common/btn_rifiuta_P.svg"
        shadowImage: "../../images/common/ombra_btn_rispondi.svg"
        defaultImage: "../../images/common/ico_rifiuta.svg"
        pressedImage: "../../images/common/ico_rifiuta_P.svg"
        onPressed: control.rightClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 9
            right: parent.right
            rightMargin: 7
        }
    }

    states: [
        State {
            name: "answerReject"
            extend: ""
        },
        State {
            name: "terminate"
            PropertyChanges { target: buttonLeft; visible: false }
            PropertyChanges {
                target: buttonRight
                defaultImageBg: "../../images/common/btn_chiudi_chiamata.svg"
                pressedImageBg: "../../images/common/btn_chiudi_chiamata_P.svg"
                shadowImage: "../../images/common/ombra_btn_rispondi_L.svg"
            }
        },
        State {
            name: "teleloop"
            PropertyChanges { target: buttonLeft; enabled: false }
            PropertyChanges { target: buttonRight; enabled: false }
        }
    ]
}
