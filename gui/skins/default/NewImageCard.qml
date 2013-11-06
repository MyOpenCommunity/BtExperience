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
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief A page to create an image card from a generic image.

  This page let the user highlight a part of an image. This highlight may be
  saved as image to be used for a card.
  For example, a user may customize her profile card from a part of a photo.
  */
BasePage {
    id: page

    property variant containerWithCard
    property string newFilename
    property alias fullImage: sourceImage.source
    property alias helpUrl: toolbar.helpUrl

    /**
      Called when home button on the toolbar is clicked.
      Default implementation navigates to home page.
      */
    function homeButtonClicked() {
        Stack.backToHome()
    }

    Rectangle {
        id: bg
        color: "white"
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
        }
    }

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: homeButtonClicked()
    }

    SvgImage {
        id: bgBottomBar

        source: "images/common/bg_bottom.svg"
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
    }

    Rectangle {
        id: bgImage

        color: "black"
        clip: true
        width: 900
        height: 427
        anchors {
            bottom: bgBottomBar.top
            bottomMargin: 10
            right: bgBottomBar.right
        }

        Image {
            id: sourceImage

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            Component.onCompleted: {
                // sourceSize is initially set to image size; we want to start
                // with a value to zero and resize image only if needed
                sourceSize.width = 0
                sourceSize.height = 0

                // computes ratios to know if we have to resize or not (we
                // resize the image if it is bigger than the frame)
                var ratioW = width / parent.width
                var ratioH = height / parent.height

                // if image is wider than frame and is wider than taller,
                // then resize its width
                if (ratioW > 1.0)
                    if (ratioW >= ratioH)
                        sourceSize.width = parent.width

                // if image is taller than frame and is taller than wider,
                // then resize its height
                if (ratioH > 1.0)
                    if (ratioH >= ratioW)
                        sourceSize.height = parent.height
            }
        }

        Item {
            // in reality a placeholder for anchors, the highlight rect is drawn with
            // 4 dark rects around it, see below
            id: transparentRect

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            // TODO define some constants?
            width: 171 //Math.min(171, sourceImage.width)
            height: 213 //Math.min(213, sourceImage.height)
        }

        // to highlight cropping region we need to draw a frame around the
        // cropping rectangle with a dark color; we cannot use a simple rect
        // below the highlight item because we cannot "remove" a color in a region
        // so we have to draw 4 rectangular dark regions around the highlighted one
        // to properly render such a frame
        Rectangle {
            id: topDarkRect
            color: privateProps.darkRectColor
            opacity: privateProps.darkRectOpacity
            anchors {
                top: bgImage.top
                left: bgImage.left
                right: bgImage.right
                bottom: transparentRect.top
            }
        }

        Rectangle {
            id: bottomDarkRect
            color: privateProps.darkRectColor
            opacity: privateProps.darkRectOpacity
            anchors {
                top: transparentRect.bottom
                left: bgImage.left
                right: bgImage.right
                bottom: bgImage.bottom
            }
        }

        Rectangle {
            id: leftDarkRect
            color: privateProps.darkRectColor
            opacity: privateProps.darkRectOpacity
            anchors {
                top: topDarkRect.bottom
                left: bgImage.left
                right: transparentRect.left
                bottom: bottomDarkRect.top
            }
        }

        Rectangle {
            id: rightDarkRect
            color: privateProps.darkRectColor
            opacity: privateProps.darkRectOpacity
            anchors {
                top: topDarkRect.bottom
                left: transparentRect.right
                right: bgImage.right
                bottom: bottomDarkRect.top
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                // centers selection rect on point click
                var clickedX = mouse.x
                var clickedY = mouse.y
                var middleX = transparentRect.x + transparentRect.width / 2
                var middleY = transparentRect.y + transparentRect.height / 2
                transparentRect.x += (clickedX - middleX)
                transparentRect.y += (clickedY - middleY)
                privateProps.adjustPosition()
            }
        }
    }

    ButtonImageThreeStates {
        id: buttonZoomOut

        defaultImageBg: "images/common/btn_45x35.svg"
        pressedImageBg: "images/common/btn_45x35_P.svg"
        shadowImage: "images/common/btn_shadow_45x35.svg"
        defaultImage: "images/common/ico_meno.svg"
        pressedImage: "images/common/ico_meno_P.svg"
        repetitionOnHold: true
        anchors {
            top: bgBottomBar.top
            topMargin: 7
            left: bgBottomBar.left
            leftMargin: 7
        }
        onClicked: privateProps.zoomOut()
    }

    ButtonImageThreeStates {
        id: buttonZoomIn

        defaultImageBg: "images/common/btn_45x35.svg"
        pressedImageBg: "images/common/btn_45x35_P.svg"
        shadowImage: "images/common/btn_shadow_45x35.svg"
        defaultImage: "images/common/ico_piu.svg"
        pressedImage: "images/common/ico_piu_P.svg"
        repetitionOnHold: true
        anchors {
            top: bgBottomBar.top
            topMargin: 7
            left: buttonZoomOut.right
            leftMargin: 4
        }
        onClicked: privateProps.zoomIn()
    }

    ButtonImageThreeStates {
        id: buttonBrowse

        defaultImageBg: "images/common/btn_45x35.svg"
        pressedImageBg: "images/common/btn_45x35_P.svg"
        shadowImage: "images/common/btn_shadow_45x35.svg"
        defaultImage: "images/common/ico_browse.svg"
        pressedImage: "images/common/ico_browse_P.svg"
        repetitionOnHold: true
        anchors {
            top: bgBottomBar.top
            topMargin: 7
            left: buttonZoomIn.right
            leftMargin: 13
        }
        onClicked: console.log("browse to be implemented")
    }

    // I didn't use the ButtonOkCancel control because it has a background
    // image; here it is better to use "simple" buttons
    ButtonThreeStates {
        id: cancelButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("CANCEL")
        font.pixelSize: 14
        onPressed: Stack.popPage()
        anchors {
            top: bgBottomBar.top
            topMargin: 7
            right: bgBottomBar.right
            rightMargin: 7
        }
    }

    ButtonThreeStates {
        id: okButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("OK")
        font.pixelSize: 14
        onPressed: {
            privateProps.saveCard()
            Stack.popPage()
        }
        anchors {
            top: bgBottomBar.top
            topMargin: 7
            right: cancelButton.left
        }
    }

    UbuntuLightText {
        text: qsTr("Save configuration changes?")
        color: "white"
        anchors {
            verticalCenter: okButton.verticalCenter
            right: okButton.left
            rightMargin: 10
        }
    }

    // all arrows are rendered with freccia_dx.svg (right arrow) rotating it
    // properly to render all arrows; I defined a bg_freccia.svg (a transparent
    // 50x50 image) to give a dimension to the buttons
    // all anchors are computed assuming buttons have 50x50 dimension
    ButtonImageThreeStates {
        id: arrowLeft

        rotation: 180
        defaultImageBg: "images/common/bg_freccia.svg"
        pressedImageBg: "images/common/bg_freccia.svg"
        defaultImage: "images/common/freccia_dx.svg"
        pressedImage: "images/common/freccia_dx_P.svg"
        repetitionOnHold: true
        anchors {
            bottom: bgImage.bottom
            bottomMargin: 10 + 50 + 10
            left: bgImage.left
            leftMargin: 10
        }
        onClicked: privateProps.leftArrowClicked()
    }

    ButtonImageThreeStates {
        id: arrowDown

        rotation: 90
        defaultImageBg: "images/common/bg_freccia.svg"
        pressedImageBg: "images/common/bg_freccia.svg"
        defaultImage: "images/common/freccia_dx.svg"
        pressedImage: "images/common/freccia_dx_P.svg"
        repetitionOnHold: true
        anchors {
            bottom: bgImage.bottom
            bottomMargin: 10
            left: bgImage.left
            leftMargin: 10 + 50 + 10
        }
        onClicked: privateProps.downArrowClicked()
    }

    ButtonImageThreeStates {
        id: arrowRight

        rotation: 0
        defaultImageBg: "images/common/bg_freccia.svg"
        pressedImageBg: "images/common/bg_freccia.svg"
        defaultImage: "images/common/freccia_dx.svg"
        pressedImage: "images/common/freccia_dx_P.svg"
        repetitionOnHold: true
        anchors {
            bottom: bgImage.bottom
            bottomMargin: 10 + 50 + 10
            left: arrowDown.right
            leftMargin: 10
        }
        onClicked: privateProps.rightArrowClicked()
    }

    ButtonImageThreeStates {
        id: arrowUp

        rotation: 270
        defaultImageBg: "images/common/bg_freccia.svg"
        pressedImageBg: "images/common/bg_freccia.svg"
        defaultImage: "images/common/freccia_dx.svg"
        pressedImage: "images/common/freccia_dx_P.svg"
        repetitionOnHold: true
        anchors {
            bottom: arrowLeft.top
            bottomMargin: 10
            left: arrowDown.left
        }
        onClicked: privateProps.upArrowClicked()
    }

    states: [
        State {
            name: "screenshot"
            PropertyChanges { target: arrowDown; visible: false; }
            PropertyChanges { target: arrowLeft; visible: false; }
            PropertyChanges { target: arrowRight; visible: false; }
            PropertyChanges { target: arrowUp; visible: false; }
        }
    ]
    QtObject {
        id: privateProps

        property real zoom: 100
        property variant originalRect: undefined

        property real darkRectOpacity: 0.5
        property color darkRectColor: "black"
        property int arrowsMargin: 50
        property int movementDelta: 10

        function doZoom(zoom_factor) {
            console.log("Zoom factor: " + zoom_factor)

            if (originalRect === undefined) {
                originalRect = Qt.rect(sourceImage.x, sourceImage.y, sourceImage.width, sourceImage.height)
            }

            var new_width = originalRect.width * zoom_factor
            sourceImage.x = originalRect.x - (new_width - originalRect.width) / 2
            sourceImage.width = new_width

            var new_height = originalRect.height * zoom_factor
            sourceImage.y = originalRect.y - (new_height - originalRect.height) / 2
            sourceImage.height = new_height
        }

        function adjustPosition() {
            // if selection rect and image have a negative x coordinate, we must
            // offset image for the minimum negative x to make the image or the
            // selection completely visible (what "comes" first)
            sourceImage.x += Math.max(0, Math.min(-transparentRect.x, -sourceImage.x))
            // once we have adjusted image to be fully visible, we must offset
            // the selection to stay inside image (if needed)
            transparentRect.x = Math.max(transparentRect.x, Math.max(sourceImage.x, 0))

            // do the same as above for y coordinate
            sourceImage.y += Math.max(0, Math.min(-transparentRect.y, -sourceImage.y))
            transparentRect.y = Math.max(transparentRect.y, Math.max(sourceImage.y, 0))

            // do the same on x coordinate, but on right edge
            var frmX = bgImage.width
            var selX = transparentRect.x + transparentRect.width // right edge
            var imgX = sourceImage.x + sourceImage.width // right edge
            sourceImage.x -= Math.max(0, Math.min(selX - frmX, imgX - frmX))
            transparentRect.x = Math.min(selX, Math.min(imgX, frmX)) - transparentRect.width

            // do the same on y coordinate, but on bottom edge
            var frmY = bgImage.height
            var selY = transparentRect.y + transparentRect.height // bottom edge
            var imgY = sourceImage.y + sourceImage.height // bottom edge
            sourceImage.y -= Math.max(0, Math.min(selY - frmY, imgY - frmY))
            transparentRect.y = Math.min(selY, Math.min(imgY, frmY)) - transparentRect.height
        }

        function zoomIn() {
            if (zoom < 500) {
                zoom *= 1.25
                doZoom(zoom / 100)
                adjustPosition()
            }
        }

        function zoomOut() {
            if (zoom > 1) {
                zoom *= 0.8
                doZoom(zoom / 100)
                adjustPosition()
            }
        }

        function leftArrowClicked() {
            transparentRect.x -= movementDelta
            adjustPosition()
        }

        function rightArrowClicked() {
            transparentRect.x += movementDelta
            adjustPosition()
        }

        function upArrowClicked() {
            transparentRect.y -= movementDelta
            adjustPosition()
        }

        function downArrowClicked() {
            transparentRect.y += movementDelta
            adjustPosition()
        }

        function saveCard() {
            // mapping item coordinates to global coordinates
            var x = transparentRect.mapToItem(null, 0, 0).x
            var y = transparentRect.mapToItem(null, 0, 0).y
            var w = transparentRect.width
            var h = transparentRect.height
            // customization filenames are in the form uii.extension
            // the string concatenation is needed to convert everything to a string
            var name = page.newFilename + "." + getExtension("" + sourceImage.source)
            page.state = "screenshot"
            containerWithCard.cardImage = global.takeScreenshot(Qt.rect(x, y, w, h), name)
            page.state = ""
            // images are internally cached and shared, so a trick is needed
            // to cause a reload of the image from disk
            containerWithCard.setCacheDirty()
        }

        function getExtension(filename) {
            return filename.split(".").pop()
        }
    }
}
