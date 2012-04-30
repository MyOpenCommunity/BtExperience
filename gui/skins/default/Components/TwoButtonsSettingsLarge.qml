import QtQuick 1.1

Row {
    id: button
    property alias rightText: rightLabel.text
    property alias leftText: leftLabel.text
    signal leftClicked
    signal rightClicked

    LargeButton {
        Text {
            id: leftLabel
            text: "-"
            anchors.centerIn: parent
            color: "#444546"
            font.pointSize: 14
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
            id: rightLabel
            text: "+"
            anchors.centerIn: parent
            color: "#444546"
            font.pointSize: 14
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
