import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack

BasePage {
    id: page
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
        property real darkRectOpacity: 0.5
        property color darkRectColor: "black"
        property int arrowsMargin: 50
        property int movementDelta: 10

        function leftArrowClicked() {
            if (transparentRect.x - movementDelta >= sourceImage.x)
                transparentRect.x -= movementDelta
            else // align to the left margin
                transparentRect.x = sourceImage.x
        }

        function rightArrowClicked() {
            if (transparentRect.x + transparentRect.width + movementDelta <= sourceImage.x + sourceImage.width)
                transparentRect.x += movementDelta
            else // align to the right margin
                transparentRect.x = sourceImage.x + sourceImage.width - transparentRect.width
        }

        function topArrowClicked() {
            if (transparentRect.y - movementDelta >= sourceImage.y)
                transparentRect.y -= movementDelta
            else // align to the top margin
                transparentRect.y = sourceImage.y
        }

        function bottomArrowClicked() {
            if (transparentRect.y + transparentRect.height + movementDelta <= sourceImage.y + sourceImage.height)
                transparentRect.y += movementDelta
            else // align to the bottom margin
                transparentRect.y = sourceImage.y + sourceImage.height - transparentRect.height
        }

        function saveCard() {
            global.takeScreenshot(Qt.rect(transparentRect.x, transparentRect.y,
                                          transparentRect.width, transparentRect.height))
        }
    }

    Image {
        id: sourceImage
        source: "images/home/card_1.png"
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
        source: "images/common/pager_arrow_next.svg"
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
        source: "images/common/pager_arrow_next.svg"
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
        source: "images/common/pager_arrow_next.svg"
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
        source: "images/common/pager_arrow_previous.svg"
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
        onOkClicked: privateProps.saveCard()
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
