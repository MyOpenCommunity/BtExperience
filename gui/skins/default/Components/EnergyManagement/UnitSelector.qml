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


SvgImage {
    id: control

    property variant load
    property bool showCurrency

    source: "../../images/common/bg_on-off.svg"
    height: 40

    Row {
        anchors.centerIn: parent

        ButtonThreeStates {
            id: moneyButton

            font.pixelSize: 14
            defaultImage: "../../images/common/btn_66x35.svg"
            pressedImage: "../../images/common/btn_66x35_P.svg"
            selectedImage: "../../images/common/btn_66x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_66x35.svg"
            text: load.rate.currencySymbol
            status: showCurrency === true ? 1 : 0
            onClicked: showCurrency = true
            enabled: load.rate !== null
        }

        ButtonThreeStates {
            id: consumptionButton

            font.pixelSize: 14
            defaultImage: "../../images/common/btn_66x35.svg"
            pressedImage: "../../images/common/btn_66x35_P.svg"
            selectedImage: "../../images/common/btn_66x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_66x35.svg"
            text: load.cumulativeUnit
            status: showCurrency === false ? 1 : 0
            onClicked: showCurrency = false
        }
    }
}
