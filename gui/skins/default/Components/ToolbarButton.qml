import QtQuick 1.1
import Components.Text 1.0


Row {
    id: control

    property bool blinking: false
    property alias blinkingInterval: blinkingTimer.interval
    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage
    property alias enabled: button.enabled
    property int quantity: 0

    signal clicked

    visible: quantity > 0

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

        SvgImage {
            id: quantityBg
            // normally, we put images outside for performance reasons
            // here we are in a Row element and we cannot do that (the Row will
            // grow in size to make room for this image)
            visible: quantity > 0
            source: "../images/toolbar/bg_counter.svg"
            anchors {
                bottom: button.bottom
                bottomMargin: 10
                right: button.right
                rightMargin: 5
            }
        }

        UbuntuLightText {
            // see comment above
            text: quantity
            visible: quantity > 0
            color: "white"
            font.pixelSize: 10
            anchors.fill: quantityBg
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
