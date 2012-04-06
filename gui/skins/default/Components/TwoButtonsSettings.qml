import QtQuick 1.1

Row {
    id: button
    width: 208
    height: 50
    property string leftImage: ""
    property string rightImage: ""
    signal leftClicked
    signal rightClicked

    Image {
        source: "../images/common/btn_comando.png"
        width: parent.width / 2
        height: 50
        Image {
            source: button.leftImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.leftClicked()
            onPressed: leftTimer.running = true
            onReleased: leftTimer.running = false
        }

        Timer {
            id: leftTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: button.leftClicked()
        }
    }

    Image {
        source: "../images/common/btn_comando.png"
        width: parent.width / 2
        height: 50
        Image {
            source: button.rightImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.rightClicked()
            onPressed: rightTimer.running = true
            onReleased: rightTimer.running = false
        }

        Timer {
            id: rightTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: button.rightClicked()
        }
    }
}
