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


SvgImage {
    id: control

    property string text: "7 seconds"
    property string title: "temperature"

    signal leftClicked
    signal rightClicked

    source: "../images/common/panel_212x73.svg"

    UbuntuLightText {
        id: title
        color: "black"
        text: control.title
        font.pixelSize: 15
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
            right: parent.right
            rightMargin: 7
        }
        elide: Text.ElideMiddle
    }

    ControlLeftRight {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onLeftClicked: control.leftClicked()
        onRightClicked: control.rightClicked()
        text: control.text
    }
}
