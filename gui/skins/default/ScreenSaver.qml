import QtQuick 1.1



Rectangle {
    id: screensaver

    property alias source: component.source

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

    Timer {
        interval: 1000;
        running: true;
        repeat: true;
        onTriggered: screensaverMgmt()
    }

    function screensaverMgmt() {
        // TODO manage activation time (now it is hardcoded!)
        if (global.lastTimePress > 60)
            screensaver.opacity = 0.8
        else
            screensaver.opacity = 0
    }
}
