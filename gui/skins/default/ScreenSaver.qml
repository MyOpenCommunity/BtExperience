import QtQuick 1.1



Rectangle {
    id: screensaver

    property string screensaverFile

    width: global.mainWidth
    height: global.mainHeight
    z: 20
    color: "black"
    opacity: 0

    MouseArea {
        anchors {
            fill: parent
        }
    }

    Loader {
        id: component
        z: 21
        anchors {
            fill: parent
        }
    }

    states: [
        State {
            name: "SCREENSAVER_ON"
            // TODO manage activation time (now it is hardcoded!)
            when: global.lastTimePress > 60
            PropertyChanges { target: screensaver; opacity: 0.8}
            PropertyChanges {
                target: component
                source: screensaver.screensaverFile
            }
        }
    ]
}
