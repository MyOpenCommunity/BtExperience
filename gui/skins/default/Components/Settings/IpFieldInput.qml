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

FocusScope {
    id: ipFieldInput

    height: background.height

    property alias text: editField.text
    property bool validInput: text < 256
    property variant containerWidget

    signal skipField

    SvgImage {
        id: background
        source: "../../images/common/bg_text-input.svg"
        width: parent.width

        UbuntuMediumTextInput {
            id: editField
            anchors.fill: parent
            anchors.topMargin: 5
            font.pixelSize: 20
            color: "#5A5A5A"
            horizontalAlignment: Text.AlignHCenter
            text: ipFieldInput.value
            onTextChanged: privateProps.testChar()
            maximumLength: 3
            focus: true
            containerWidget: ipFieldInput.containerWidget

            Timer {
                id: selectTimer
                interval: 1
                onTriggered: editField.selectAll()
            }

            // TODO: This code only works with a physical keyboard, not with
            // a virtual one, because the input event from a virtual keyboard
            // uses another code path. We can workaround the issue, but only
            // if it's really worth it.
            Keys.onPressed: {
                // TODO: if field is selected and we press a non digit key, we
                // delete the field; if this is a problem, we need to filter
                // all non-digit keys here.
                if (event.key === Qt.Key_Period) {
                    event.accepted = true
                    deselect()
                    ipFieldInput.skipField()
                }
            }

            onActiveFocusChanged: {
                if (activeFocus)
                    selectTimer.restart()
            }
        }

        Rectangle {
            color: "transparent"
            anchors.fill: parent
            border.width: 2
            border.color: "red"
            opacity: 0.4
            visible: editField.text > 255
        }

        QtObject {
            id: privateProps

            function testChar() {
                var currentPos = editField.cursorPosition
                var lastChar = editField.text.charAt(currentPos - 1)
                if ("0123456789".indexOf(lastChar) < 0) {
                    // remove char
                    editField.text = editField.text.slice(0, currentPos - 1) + editField.text.slice(currentPos)
                }
            }
        }
    }
}
