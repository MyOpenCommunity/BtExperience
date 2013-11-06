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
  * A control to use as base for video stream from a camera.
  * The control has a status bar containing a description and a button to
  * loop between the various cameras.
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    property alias label: statusLabel.text
    property alias nextButtonVisible: nextButton.visible
    property alias color: bg_video.color
    property bool moveArrowsVisible: false

    signal nextClicked
    signal leftArrowPressed
    signal leftArrowReleased
    signal rightArrowPressed
    signal rightArrowReleased
    signal upArrowPressed
    signal upArrowReleased
    signal downArrowPressed
    signal downArrowReleased

    source: "../../images/common/bordo_video.svg"

    QtObject {
        id: privateProps

        property int margin: 5 // space between arrow and border
        property int barHeight: statusBar.height // we have to take account for the bottom bar

        // base offsets computed without considering the bar at the bottom of the video area
        property int hOffset: (bg.width - arrowRight.width) / 2 - margin
        property int vOffset: (bg.height - arrowRight.height) / 2 - margin

        // horizontal and vertical offsets (considering the bottom bar) for
        // all the arrows
        property int leftHOffset: -hOffset
        property int leftVOffset: - barHeight / 2
        property int rightHOffset: hOffset
        property int rightVOffset: - barHeight / 2
        property int upHOffset: 0
        property int upVOffset: - vOffset
        property int downHOffset: 0
        property int downVOffset: vOffset - barHeight
    }

    SvgImage {
        id: video

        source: "../../images/common/video.svg"
        anchors.centerIn: parent

        Rectangle {
            id: bg_video
            color: "black"
            width: 640
            height: 480
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: statusBar

        source: "../../images/common/bg_nome_video.svg"
        anchors {
            left: video.left
            right: video.right
            bottom: video.bottom
        }
    }

    UbuntuMediumText {
        id: statusLabel

        text: "Posto Esterno 1"
        font.pixelSize: 16
        color: "white"
        anchors {
            left: statusBar.left
            leftMargin: 10
            right: nextButton.left
            rightMargin: 10
            verticalCenter: statusBar.verticalCenter
        }
        elide: Text.ElideRight
    }

    ButtonImageThreeStates {
        id: nextButton

        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_cicla.svg"
        pressedImage: "../../images/common/ico_cicla_P.svg"
        onPressed: nextClicked()
        anchors {
            right: statusBar.right
            rightMargin: 10
            bottom: statusBar.bottom
            bottomMargin: 7
        }
    }

    // all arrows are rendered with freccia_dx.svg (right arrow) rotating it
    // properly to render all arrows; I defined a bg_freccia.svg (a transparent
    // 50x50 image) to give a dimension to the buttons
    ButtonImageThreeStates {
        id: arrowLeft

        visible: bg.moveArrowsVisible
        rotation: 180
        defaultImageBg: "../../images/common/bg_freccia.svg"
        pressedImageBg: "../../images/common/bg_freccia.svg"
        defaultImage: "../../images/common/freccia_dx.svg"
        pressedImage: "../../images/common/freccia_dx_P.svg"
        anchors {
            centerIn: video
            horizontalCenterOffset: privateProps.leftHOffset
            verticalCenterOffset: privateProps.leftVOffset
        }
        onPressed: leftArrowPressed()
        onReleased: leftArrowReleased()
    }

    ButtonImageThreeStates {
        id: arrowDown

        visible: bg.moveArrowsVisible
        rotation: 90
        defaultImageBg: "../../images/common/bg_freccia.svg"
        pressedImageBg: "../../images/common/bg_freccia.svg"
        defaultImage: "../../images/common/freccia_dx.svg"
        pressedImage: "../../images/common/freccia_dx_P.svg"
        anchors {
            centerIn: video
            horizontalCenterOffset: privateProps.downHOffset
            verticalCenterOffset: privateProps.downVOffset
        }
        onPressed: downArrowPressed()
        onReleased: downArrowReleased()
    }

    ButtonImageThreeStates {
        id: arrowRight

        visible: bg.moveArrowsVisible
        rotation: 0
        defaultImageBg: "../../images/common/bg_freccia.svg"
        pressedImageBg: "../../images/common/bg_freccia.svg"
        defaultImage: "../../images/common/freccia_dx.svg"
        pressedImage: "../../images/common/freccia_dx_P.svg"
        anchors {
            centerIn: video
            horizontalCenterOffset: privateProps.rightHOffset
            verticalCenterOffset: privateProps.rightVOffset
        }
        onPressed: rightArrowPressed()
        onReleased: rightArrowReleased()
    }

    ButtonImageThreeStates {
        id: arrowUp

        visible: bg.moveArrowsVisible
        rotation: 270
        defaultImageBg: "../../images/common/bg_freccia.svg"
        pressedImageBg: "../../images/common/bg_freccia.svg"
        defaultImage: "../../images/common/freccia_dx.svg"
        pressedImage: "../../images/common/freccia_dx_P.svg"
        anchors {
            centerIn: video
            horizontalCenterOffset: privateProps.upHOffset
            verticalCenterOffset: privateProps.upVOffset
        }
        onPressed: upArrowPressed()
        onReleased: upArrowReleased()
    }
}
