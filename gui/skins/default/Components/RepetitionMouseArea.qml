import QtQuick 1.1

BeepingMouseArea {
    id: mouseArea
    property bool repetitionEnabled: false

    onPressed: clickTimer.running = repetitionEnabled
    onReleased: clickTimer.running = false
    onVisibleChanged: {
        if (visible === false)
            clickTimer.running = false
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
            mouseArea.clicked(mouseArea)
        }
    }
}
