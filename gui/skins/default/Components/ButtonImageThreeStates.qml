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

    // images for button background
    property url defaultImageBg: ""
    property url pressedImageBg: ""
    property url selectedImageBg: ""

    // image for button shadow
    property url shadowImage: ""

    // images on top of the button
    property url defaultImage: ""
    property url pressedImage: ""
    property url selectedImage: ""

    property bool enabled: true
    property int status: 0 // 0 - up, 1 - down

    property alias repetitionOnHold: area.repetitionEnabled // enable repetition when pressed
    property alias repetitionTriggered: area.repetitionTriggered
    property alias repetitionWithSlowFastClicks: area.repetitionWithSlowFastClicks
    property alias slowInterval: area.slowInterval
    property alias fastInterval: area.fastInterval

    signal clicked
    signal pressed
    signal released
    signal touched
    signal clickedSlow
    signal clickedFast

    source: defaultImageBg

    RepetitionMouseArea {
        id: area
        anchors.fill: parent
        onPressed: {
            touchTimer.restart()
            bg.pressed()
        }
        onReleased: bg.released()
        onClicked: bg.clicked()
        onClickedSlow: bg.clickedSlow()
        onClickedFast: bg.clickedFast()
        visible: bg.enabled

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: bg.touched()
        }
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: parent.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    SvgImage {
        id: topImage
        anchors.centerIn: parent
        source: defaultImage
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
            PropertyChanges { target: bg; source: pressedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: pressedImage }
        },
        State {
            name: "selected"
            when: (status === 1)
            PropertyChanges { target: bg; source: selectedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: selectedImage }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: bg; source: defaultImageBg }
            PropertyChanges { target: shadow; visible: true }
            PropertyChanges { target: topImage; source: defaultImage }
        }
    ]
}
