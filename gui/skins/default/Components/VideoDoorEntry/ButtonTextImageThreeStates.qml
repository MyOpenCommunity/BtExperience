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
    property alias textColor: caption.color

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
    property alias imageAnchors: topImage.anchors

    property bool enabled: true // button accepts input or not
    property int status: 0 // 0 - up, 1 - down
    property bool timerEnabled: false // enable repetion when pressed

    signal clicked

    source: defaultImageBg

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: bg.clicked()
        // in some cases I have to disable the button to not accept any input
        visible: bg.enabled
        onPressed: clickTimer.running = timerEnabled
        onReleased: clickTimer.running = false
        onVisibleChanged: {
            if (visible === false)
                clickTimer.running = false
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
        color: "gray"
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

    Timer {
        id: clickTimer

        property int activations: 0

        onRunningChanged: {
            if (running) {
                activations = 1
                interval = 500
            }
        }

        interval: 500
        running: false
        repeat: true
        onTriggered: {
            if (++activations === 4)
                interval = 200
            bg.clicked()
        }
    }

    // for the reasons behind normal state see ButtonThreeStates
    states: [
        State {
            name: "pressed"
            when: (area.pressed) && (status === 0)
            PropertyChanges { target: bg; source: pressedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: pressedImage }
            PropertyChanges { target: caption; color: "white" }
        },
        State {
            name: "selected"
            when: (status === 1)
            PropertyChanges { target: bg; source: selectedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: selectedImage }
            PropertyChanges { target: caption; color: "white" }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: bg; source: selectedImageBg }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: topImage; source: selectedImage }
            PropertyChanges { target: caption; color: "white" }
        }
    ]
}
