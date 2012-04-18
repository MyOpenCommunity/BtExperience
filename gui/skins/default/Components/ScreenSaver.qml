import QtQuick 1.1



Rectangle {
    id: screensaver

    property variant screensaverComponent
    property int timeout: global.guiSettings.timeOutInSeconds
    property int w: global.mainWidth
    property int h: global.mainHeight

    width: w
    height: h
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
            name: "running"
            when: global.lastTimePress > screensaver.timeout
            PropertyChanges { target: screensaver; opacity: 0.8}
            PropertyChanges {
                target: component
                sourceComponent: screensaverComponent
            }
        }
    ]
}
