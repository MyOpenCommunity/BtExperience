import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300
        Component.onCompleted: controlCall.state = "command"
        ControlCall {
            id: controlCall
            onMinusClicked: console.log("minusClicked")
            onPlusClicked: console.log("plusClicked")
            onControlClicked: {
                controlCall.state = "outgoingCall"
                console.log("controlClicked")
                answerTimeout.start();
            }
            onLeftButtonClicked: console.log("leftButtonClicked")
            onStopCallClicked: {
                // stop fake timer
                answerTimeout.stop()
                console.log("stopCall clicked")
                controlCall.state = "command"
                // TODO: send stop call frame
            }
            onMuteClicked: console.log("mute clicked")
        }
    }

    Timer {
        id: answerTimeout
        interval: 2000
        onTriggered: controlCall.state = "noAnswer"
    }
}
