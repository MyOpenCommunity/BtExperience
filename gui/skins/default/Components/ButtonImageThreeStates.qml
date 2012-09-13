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

    property bool enabled: true // button accepts input or not
    property int status: 0 // 0 - up, 1 - down
    property bool repetitionOnHold: false // enable repetition when pressed

    signal clicked
    signal pressed
    signal released

    source: defaultImageBg

    BeepingMouseArea {
        id: area
        anchors.fill: parent
        onClicked: bg.clicked()
        // in some cases I have to disable the button to not accept any input
        visible: bg.enabled
        onPressed: {
            bg.pressed()
            clickTimer.running = repetitionOnHold
        }
        onReleased: {
            bg.released()
            clickTimer.running = false
        }
        onVisibleChanged: {
            if (visible === false)
                clickTimer.running = false
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
