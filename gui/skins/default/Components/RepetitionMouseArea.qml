import QtQuick 1.1

BeepingMouseArea {
    id: mouseArea

    property bool repetitionEnabled: false
    property bool repetitionTriggered: clickTimer.activations > 1
    property int slowInterval: 350
    property int fastInterval: 100

    signal clickedSlow
    signal clickedFast

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
                interval = slowInterval
            }
        }

        interval: slowInterval
        running: false
        repeat: true
        onTriggered: {
            if (activations++ === 5)
                interval = fastInterval
            mouseArea.clicked(mouseArea)
            if (interval === fastInterval)
                mouseArea.clickedFast(mouseArea)
            else
                mouseArea.clickedSlow(mouseArea)
        }
    }
}
