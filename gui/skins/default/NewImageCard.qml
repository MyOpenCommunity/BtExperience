import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: page

    property variant containerWithCard
    property alias fullImage: sourceImage.source

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
        onClicked: Stack.popPage()
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
        onClicked: {
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

    QtObject {
        id: privateProps

        property int zoom: 100
        property int zoomStep: 10
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
            var name = "card_" + containerWithCard.uii + "." + getExtension("" + sourceImage.source)
            containerWithCard.cardImage = global.takeScreenshot(Qt.rect(x, y, w, h), name)
            // images are internally cached and shared, so a trick is needed
            // to cause a reload of the image from disk
            containerWithCard.setCacheDirty()
        }

        function getExtension(filename) {
            return filename.split(".").pop()
        }
    }
}
