import QtQuick 1.1

Rectangle {
    id: bouncer

    color: "black"
    opacity: 0.8

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
                duration: 6000
                easing.type: Easing.Linear
            }
            NumberAnimation {
                to: 0
                duration: 6000
                easing.type: Easing.Linear
            }
        }

        SequentialAnimation on y {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: bouncer.height - image.height
                duration: 9000
                easing.type: Easing.OutBounce
            }
            NumberAnimation {
                to: 0
                duration: 1500
                easing.type: Easing.Linear
            }
        }
    }
}
