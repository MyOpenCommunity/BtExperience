import QtQuick 1.1
import Components 1.0

Rectangle {
    id: button

    signal buttonClicked

    width: btn.width
    height: btn.height

    Column{
        SvgImage {
            id: btn
            source: mouseArea.pressed ? "../images/common/button_1-3_p.svg" :
                                        "../images/common/button_1-3.svg"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: buttonClicked()
                onPressed: clickTimer.running = true
                onReleased: clickTimer.running = false
            }
        }

        SvgImage {
            source: "../images/common/shadow_button_1-3.svg"
            visible: mouseArea.pressed === false
        }
    }

    Timer {
        id: clickTimer

        property int activations: 0

        onRunningChanged: {
            if (running) {
                activations = 1
                interval = 500
                buttonClicked()
            }
        }

        interval: 500
        running: false
        repeat: true
        onTriggered: {
            if (++activations === 4)
                interval = 200
            buttonClicked()
        }
    }
}

