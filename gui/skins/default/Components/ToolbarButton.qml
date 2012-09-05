import QtQuick 1.1


Row {
    id: control

    property bool blinking: false
    property alias blinkingInterval: blinkingTimer.interval
    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage
    property alias enabled: button.enabled

    signal clicked

    // separator
    SvgImage {
        id: separator

        visible: control.visible
        source: "../images/toolbar/toolbar_separator.svg"
        height: control.height
    }

    // button
    ButtonImageThreeStates {
        id: button

        visible: control.visible
        defaultImageBg: "../images/toolbar/_bg_alert.svg"
        pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
        defaultImage: "../images/toolbar/icon_vde-mute.svg"
        pressedImage: "../images/toolbar/icon_vde-mute.svg"
        onClicked: control.clicked()
        status: 0

        Behavior on opacity {
            NumberAnimation { duration: blinkingTimer.interval }
        }

        // blinking is managed externally (we still don't have blinking buttons),
        // but it can be a button feature if used more
        Timer {
            id: blinkingTimer

            running: control.blinking
            interval: 500
            repeat: true
            onTriggered: button.opacity === 1 ? button.opacity = 0 : button.opacity = 1
        }
    }
}
