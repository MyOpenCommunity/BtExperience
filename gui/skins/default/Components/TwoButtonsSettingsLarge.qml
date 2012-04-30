import QtQuick 1.1

Row {
    id: button
    signal leftClicked
    signal rightClicked

    LargeButton {
        Text {
            text: "-"
            anchors.centerIn: parent
        }
        onButtonClicked: button.leftClicked()
        onButtonPressed: leftTimer.running = true
        onButtonReleased: leftTimer.running = false

        Timer {
            id: leftTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: button.leftClicked()
        }
    }

    LargeButton {
        Text {
            text: "+"
            anchors.centerIn: parent
        }
        onButtonClicked: button.rightClicked()
        onButtonPressed: rightTimer.running = true
        onButtonReleased: rightTimer.running = false

        Timer {
            id: rightTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: button.rightClicked()
        }
    }
}
