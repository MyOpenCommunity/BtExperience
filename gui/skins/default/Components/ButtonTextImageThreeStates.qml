/**
  * A control that implements a text and an image that can have 3 states.
  * The 3 states are:
  *     - default
  *     - pressed
  *     - selected
  * Text is on the left while the image is on the right.
  * Text and image change together in the various states.
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    // the label on the left
    property string text: "premi per parlare"
    property color textColor: "gray"
    property color pressedTextColor: "white"

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

    // some additional properties
    property alias textAnchors: caption.anchors
    property alias imageAnchors: topImage.anchors

    property bool enabled: true // button accepts input or not
    property int status: 0 // 0 - up, 1 - down
    property alias repetitionOnHold: area.repetitionEnabled // enable repetion when pressed

    signal clicked
    signal pressed
    signal touched

    source: defaultImageBg

    RepetitionMouseArea {
        id: area
        anchors.fill: parent
        onClicked: bg.clicked()
        onPressed: {
            touchTimer.restart()
            bg.pressed()
        }
        visible: bg.enabled

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: bg.touched()
        }
    }

    UbuntuMediumText {
        id: caption

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 11
        }
        font.pixelSize: 14
        color: bg.textColor
        text: bg.text
    }

    SvgImage {
        id: topImage
        source: defaultImage
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
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
            PropertyChanges { target: caption; color: bg.pressedTextColor }
        },
        State {
            name: "selected"
            when: (status === 1)
            PropertyChanges { target: bg; source: selectedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: selectedImage }
            PropertyChanges { target: caption; color: bg.pressedTextColor }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: bg; source: defaultImageBg }
            PropertyChanges { target: shadow; visible: true }
            PropertyChanges { target: topImage; source: defaultImage }
            PropertyChanges { target: caption; color: bg.textColor }
        }
    ]
}
