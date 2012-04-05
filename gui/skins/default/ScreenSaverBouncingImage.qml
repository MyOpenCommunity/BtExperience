import QtQuick 1.1

Item {
    id: bouncer

    Image {
        id: image
        source: "images/bticino_logo.svg"
        x: 0
        y: 0
        width: 236
        height: 76
        sourceSize.width: 236
        sourceSize.height: 76

        SequentialAnimation on x {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: global.mainWidth - image.width
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
                to: global.mainHeight - image.height
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
