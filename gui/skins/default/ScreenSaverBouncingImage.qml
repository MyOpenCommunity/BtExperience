import QtQuick 1.1

Item {
    id: bouncer
    property int duration_x: 4000
    property int duration_y: 5000

    Image {
        id: image
        source: "images/bticino_logo.jpg"

        SequentialAnimation on x {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: global.mainWidth - image.width
                duration: bouncer.duration_x
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                to: 0
                duration: bouncer.duration_x
                easing.type: Easing.InOutQuad
            }
        }

        SequentialAnimation on y {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                to: global.mainHeight - image.height
                duration: bouncer.duration_y
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                to: 0
                duration: bouncer.duration_y
                easing.type: Easing.InOutQuad
            }
        }
    }
}
