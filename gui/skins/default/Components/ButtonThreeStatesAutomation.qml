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
    id: bg

    property url defaultImage: ""
    property url pressedImage: ""
    property url selectedImage: ""
    property url defaultIcon: ""
    property url pressedIcon: ""
    property url selectedIcon: ""
    property url shadowImage: ""

    property alias text: label.text
    property alias font: label.font
    property alias textAnchors: label.anchors
    property alias horizontalAlignment: label.horizontalAlignment

    property bool enabled: true
    property int status: 0 // 0 - up, 1 - down

    signal pressed(variant mouse)
    signal clicked(variant mouse)
    signal released(variant mouse)
    signal touched

    source: defaultImage

    BeepingMouseArea {
        id: area
        anchors.fill: parent
        onPressed: {touchTimer.restart();bg.pressed(mouse)} //;console.log("ButtonThreeStatesAutomation.qml clicked!")}
        onReleased: {bg.released(mouse)} //;console.log("ButtonThreeStatesAutomation.qml released!")}
        // in some cases I have to disable the button to not accept any input
        visible: bg.enabled
        Timer {
            id: touchTimer
            interval: 50
            onTriggered: bg.touched()
        }
    }

    UbuntuLightText {
        id: label
        color: "black"
        anchors.centerIn: parent
        wrapMode: Text.WordWrap
    }

    SvgImage {
        id: icon
        anchors.centerIn: parent
        source: defaultIcon
    }

    SvgImage {
        id: shadow
        anchors {
            left: bg.left
            top: bg.bottom
            right: bg.right
        }
        source: shadowImage
    }

    // for the reasons behind normal state see ButtonThreeStates
    states: [
        State {
            name: "pressed"
            when: (area.pressed) && (status === 0)
            PropertyChanges { target: bg; source: pressedImage }
            PropertyChanges { target: icon; source: pressedIcon }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: label; color: "white" }
        },
        State {
            name: "selected"
            when: status === 1 && !(area.pressed)
            PropertyChanges { target: bg; source: defaultImage }
            PropertyChanges { target: icon; source: "" }
            PropertyChanges { target: label; text: "STOP" }
        },
        State {
            name: "selected_pressed"
            when: area.pressed && status === 1
            PropertyChanges { target: bg; source: pressedImage }
            PropertyChanges { target: icon; source: "" }
            PropertyChanges { target: label; text: "STOP" }
        }   
    ]
}
