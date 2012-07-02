import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack

BasePage {
    id: page

    Rectangle {
        color: "white"
        anchors.fill: parent
    }

    ToolBar { // does not work, it is just for homogeneity with other pages.
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    QtObject {
        id: privateProps
        property int zoom: 100
        property int zoomStep: 25
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
            sourceImage.y = originalRect.y - (new_height- originalRect.height) / 2
            sourceImage.height = new_height
        }

        function adjustPosition() {
            if (transparentRect.x < sourceImage.x)
                transparentRect.x = sourceImage.x

            if (transparentRect.x + transparentRect.width > sourceImage.x + sourceImage.width)
                transparentRect.x = sourceImage.x + sourceImage.width - transparentRect.width

            if (transparentRect.y < sourceImage.y)
                transparentRect.y = sourceImage.y

            if (transparentRect.y + transparentRect.height > sourceImage.y + sourceImage.height)
                transparentRect.y = sourceImage.y + sourceImage.height - transparentRect.height
        }

        function zoomIn() {
            if (zoom < 200) {
                zoom += zoomStep
                doZoom(zoom / 100)
                adjustPosition()
            }
        }

        function zoomOut() {
            if (zoom > 25) {
                zoom -= zoomStep
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

        function topArrowClicked() {
            transparentRect.y -= movementDelta
            adjustPosition()
        }

        function bottomArrowClicked() {
            transparentRect.y += movementDelta
            adjustPosition()
        }

        function saveCard() {
            global.takeScreenshot(Qt.rect(transparentRect.x, transparentRect.y,
                                          transparentRect.width, transparentRect.height), "images/home/newcard.png")
        }
    }

    Row {
        z: 1
        spacing: 10

        anchors {
            right: parent.right
            rightMargin: 50
            top: parent.top
            topMargin: 60
        }

        UbuntuLightText {
            id: zoomText
            text: privateProps.zoom + "%"
            color: "white"
            font.pixelSize: 15
            anchors.verticalCenter: zoomControls.verticalCenter
        }

        TwoButtonsSettingsLarge {
            id: zoomControls
            onLeftClicked: privateProps.zoomOut()
            onRightClicked: privateProps.zoomIn()
        }
    }

    Image {
        id: sourceImage
        source: "images/common/addams.jpg"
        x: (page.width - width) / 2
        y: (page.height - height) / 2
    }

    Item {
        id: transparentRect
        x: (page.width - width) / 2
        y: (page.height - height) / 2
        width: 150
        height: 208
    }

    SvgImage {
        source: "images/common/freccia_dx.svg"
        anchors {
            top: parent.top
            topMargin: privateProps.arrowsMargin
            horizontalCenter: parent.horizontalCenter
        }
        rotation: 270

        MouseArea {
            anchors.fill: parent
            onClicked: privateProps.topArrowClicked()
        }
    }

    SvgImage {
        source: "images/common/freccia_dx.svg"
        anchors {
            bottom: parent.bottom
            bottomMargin: privateProps.arrowsMargin
            horizontalCenter: parent.horizontalCenter
        }
        rotation: 90

        MouseArea {
            anchors.fill: parent
            onClicked: privateProps.bottomArrowClicked()
        }
    }

    SvgImage {
        source: "images/common/freccia_dx.svg"
        anchors {
            right: parent.right
            rightMargin: privateProps.arrowsMargin
            verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: privateProps.rightArrowClicked()
        }
    }

    SvgImage {
        source: "images/common/freccia_sx.svg"
        anchors {
            left: parent.left
            leftMargin: privateProps.arrowsMargin
            verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: privateProps.leftArrowClicked()
        }
    }

    ButtonOkCancel {
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        z: 1

        onCancelClicked: Stack.popPage()
        onOkClicked: {
            privateProps.saveCard()
            // Stack.popPage()
        }
    }


    Rectangle {
        id: topDarkRect
        color: privateProps.darkRectColor
        opacity: privateProps.darkRectOpacity
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: transparentRect.top
        }
    }

    Rectangle {
        id: bottomDarkRect
        color: privateProps.darkRectColor
        opacity: privateProps.darkRectOpacity
        anchors {
            top: transparentRect.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    Rectangle {
        id: leftDarkRect
        color: privateProps.darkRectColor
        opacity: privateProps.darkRectOpacity
        anchors {
            top: topDarkRect.bottom
            left: parent.left
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
            right: parent.right
            bottom: bottomDarkRect.top
        }
    }

}
