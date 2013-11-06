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
import BtExperience 1.0
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief The Calibration page.

  This page implements the calibration procedure.
  A crosshair is displayed at the four corners of the video area and finally
  at the center. Every time the user must click on it to advance to the next
  point.
  When user clicked on all points, user has to click on two buttons that
  appear in sequence.
  If user succeeds, calibration data is saved.
  */
BasePage {
    id: page

    property int offset: 50

    property variant points: [
        {"p": {"x": offset, "y": offset}, "where": Calibration.TopLeft},
        {"p": {"x": width - offset, "y": offset}, "where": Calibration.TopRight},
        {"p": {"x": width - offset, "y": height - offset}, "where": Calibration.BottomRight},
        {"p": {"x": offset, "y": height - offset}, "where": Calibration.BottomLeft},
        {"p": {"x": width / 2, "y": height / 2}, "where": Calibration.Center}
    ]
    property int currentPoint: 0
    property bool testButtons: false

    Rectangle {
        id: bg
        color: "white"
        anchors.fill: parent
    }

    Image {
        id: crosshair
        source: "images/common/ico_elimina.svg"

        Behavior on x { NumberAnimation { duration: 200; } }
        Behavior on y { NumberAnimation { duration: 200; } }
    }

    UbuntuLightText {
        id: centerText
        text: qsTr("Click the cross")
        anchors.centerIn: page
        anchors.verticalCenterOffset: -page.height / 4
    }

    function updateCrosshair() {
        var nextPoint = page.points[page.currentPoint].p
        crosshair.x = nextPoint.x - crosshair.width / 2
        crosshair.y = nextPoint.y - crosshair.height / 2
    }

    Connections {
        target: global.calibration
        onRawMousePress: {
            if (!testButtons) {
                var scalingFactorX = global.mainWidth / 1024
                var scalingFactorY = global.mainHeight / 600
                var screenPoint = Qt.point(page.points[page.currentPoint].p.x * scalingFactorX,
                                           page.points[page.currentPoint].p.y * scalingFactorY)
                global.calibration.setCalibrationPoint(page.points[page.currentPoint].where,
                                                       screenPoint,
                                                       Qt.point(x, y))

                page.currentPoint += 1
                if (page.currentPoint >= page.points.length) {
                    console.log("Calibration done")
                    if (global.calibration.applyCalibration()) {
                        testButtons = true
                        state = "testButton1"
                        return
                    }
                    else {
                        global.calibration.resetCalibration()
                        currentPoint = 0
                    }
                }

                updateCrosshair()
            }
        }
    }

    ButtonThreeStates {
        id: button1

        anchors {
            top: parent.top
            topMargin: offset - height / 2
            left: parent.left
            leftMargin: offset - width / 4
        }
        visible: false

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        selectedImage: "images/common/btn_99x35_S.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("ok")
        font.pixelSize: 14
        onClicked: {
            page.state = "testButton2"
            console.log("button1 clicked")
        }
    }

    ButtonThreeStates {
        id: button2

        anchors {
            bottom: parent.bottom
            bottomMargin: offset - height / 2
            right: parent.right
            rightMargin: offset - width / 4
        }
        visible: false

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        selectedImage: "images/common/btn_99x35_S.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("ok")
        font.pixelSize: 14
        onClicked: {
            console.log("button2 clicked")
            backoutTimer.stop()
            global.calibration.saveCalibration()
            global.screenState.disableState(ScreenState.Calibration)
            Stack.popPage()
        }
    }

    Timer {
        id: backoutTimer
        interval: 5000
        onTriggered: {
            console.log("User didn't click on buttons on time, re-start calibration")
            testButtons = false
            global.calibration.resetCalibration()
            currentPoint = 0
            updateCrosshair()
            page.state = ""
        }
    }

    states: [
        State {
            name: "buttonsVisible"
            PropertyChanges { target: centerText; text: qsTr("Click the button") }
            PropertyChanges { target: crosshair; visible: false }
            PropertyChanges { target: backoutTimer; running: true }
        },
        State {
            name: "testButton1"
            extend: "buttonsVisible"
            PropertyChanges { target: button1; visible: true }
        },
        State {
            name: "testButton2"
            extend: "buttonsVisible"
            PropertyChanges { target: button2; visible: true }
        }
    ]

    Component.onCompleted: {
        global.screenState.enableState(ScreenState.Calibration)
        global.calibration.startCalibration()
        updateCrosshair()
    }
}
