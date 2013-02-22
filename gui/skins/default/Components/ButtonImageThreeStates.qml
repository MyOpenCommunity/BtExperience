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
    property alias largeInterval: area.largeInterval
    property alias smallInterval: area.smallInterval

    signal clicked
    signal pressed
    signal released
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
        onReleased: bg.released()
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
