import QtQuick 1.1

Rectangle {
    id: redDot
    width: 2
    height: 2
    color: "red"

    Timer {
        running: true
        interval: 10000
        onTriggered: redDot.destroy()
    }
}
