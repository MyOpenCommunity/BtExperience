import QtQuick 1.1

Row {
    id: button

    signal leftClicked
    signal rightClicked

    LargeButton {

        SvgImage {
            anchors.centerIn: parent
            source: "../images/common/symbol_minus.svg"
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

        SvgImage {
            anchors.centerIn: parent
            source: "../images/common/symbol_plus.svg"
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
