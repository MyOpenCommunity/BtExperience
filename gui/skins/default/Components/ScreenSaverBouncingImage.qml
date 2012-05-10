import QtQuick 1.1

Rectangle {
    id: bouncer
    width: 100
    height: 50

    color: "black"
    opacity: 0.8

    Rectangle {
        id: line
        y: 0
        width: bouncer.width
        height: 5
        color: "white"
        z: -1

        SequentialAnimation on y {
            running: true
            loops: Animation.Infinite
            NumberAnimation { target: line; property: "y"; to: bouncer.height - line.height; duration: 15000; easing.type: Easing.Linear }
            PropertyAction { target: line; property: "color"; value: "black"}
            NumberAnimation { target: line; property: "y"; to: 0; duration: 15000; easing.type: Easing.Linear }
            PropertyAction { target: line; property: "color"; value: "white"}
        }
    }

    Image {
        id: image
        source: "../images/bticino_logo.svg"
        x: 0
        y: 0
        width: 236 * bouncer.width / 1024
        height: 76 * bouncer.height / 600
        sourceSize.width: 236
        sourceSize.height: 76

        SequentialAnimation on x {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: bouncer.width - image.width
                duration: 15000
                easing.type: Easing.Linear
            }
            NumberAnimation {
                to: 0
                duration: 10000
                easing.type: Easing.Linear
            }
        }

        SequentialAnimation on y {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: bouncer.height - image.height
                duration: 9000
                easing.type: Easing.Linear
            }
            NumberAnimation {
                to: 0
                duration: 5000
                easing.type: Easing.Linear
            }
        }
    }
}
