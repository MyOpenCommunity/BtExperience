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
import "../../js/datetime.js" as DateTime


SvgImage {
    id: element

    property variant load
    property int partialId: 1
    property bool showCurrency

    source: "../../images/common/bg_panel_212x100.svg"

    UbuntuLightText {
        id: firstLine

        text: qsTr("Partial ") + (element.partialId + 1) // expects periodTotals are zero-based
        color: "#323232"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: parent.top
            topMargin: parent.height / 100 * 5
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
    }

    UbuntuLightText {
        id: since

        text: privateProps.computeSince(load.periodTotals[partialId])
        color: "#323232"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: firstLine.bottom
            topMargin: parent.height / 100 * 5
            left: firstLine.left
        }
        elide: Text.ElideRight
        width: parent.width / 100 * 90
    }

    UbuntuLightText {
        id: consumption

        text: privateProps.getConsumptionText(showCurrency, load.periodTotals[partialId].total, load.cumulativeUnit, load.periodTotals[partialId].totalExpense, load.rate)
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            left: firstLine.left
            verticalCenter: buttonReset.verticalCenter
        }
    }

    ButtonThreeStates {
        id: buttonReset

        defaultImage: "../../images/common/btn_66x35.svg"
        pressedImage: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        text: qsTr("reset")
        font.capitalization: Font.AllUppercase
        font.pixelSize: 15
        onClicked: load.resetTotal(partialId)
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 10
            right: parent.right
            rightMargin: parent.width / 100 * 4
        }
    }

    QtObject {
        id: privateProps

        function computeSince(period) {
            // datetime returned from resetDateTime may be invalid; in this
            // case we have to compare it with empty string, but using the
            // == operator (and not === operator) because dt is not a string
            var dt = period.resetDateTime
            var d = DateTime.format(dt)["date"]
            if (d == "")
                return ""
            var t = DateTime.format(dt)["time"]
            return qsTr("since ") + d + " - " + t
        }

        function getConsumptionText(showCurrency, consumption, currentUnit, expense, rate) {
            if (showCurrency)
                return expense + " " + rate.currencySymbol
            else
                return consumption + " " + currentUnit
        }
    }
}
