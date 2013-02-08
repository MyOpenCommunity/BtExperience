import QtQuick 1.1

BeepingMouseArea {
    id: mouseArea
    property bool repetitionEnabled: false
    property bool repetitionTriggered: clickTimer.activations > 1
    property int largeInterval: 350
    property int smallInterval: 100

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
                interval = largeInterval
            }
        }

        interval: largeInterval
        running: false
        repeat: true
        onTriggered: {
            if (activations++ === 5)
                interval = smallInterval
            mouseArea.clicked(mouseArea)
        }
    }
}
