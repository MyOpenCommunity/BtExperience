import QtQuick 1.1
import Components.Text 1.0
import "../js/Stack.js" as Stack


Item {
    id: control

    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage
    property alias enabled: button.enabled
    property int quantity: 0
    property string pageName // the page to navigate to

    // this function must be reimplemented in ToolbarButtons to define what
    // happens when user clicks on the button; it manages clicks and presses
    // automatically if you define pageName properly
    function action() {
        console.log("No action implemented in this ToolbarButton. Default image: " + defaultImage)
    }

    property bool _managed // used internally to manage clicks and presses

    visible: quantity > 0
    width: separator.width + button.width

    // separator
    SvgImage {
        id: separator

        visible: control.visible
        source: "../images/toolbar/toolbar_separator.svg"
        height: control.height
        anchors.left: parent.left
    }

    // button
    ButtonImageThreeStates {
        id: button

        visible: control.visible
        defaultImageBg: "../images/toolbar/_bg_alert.svg"
        pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
        onPressed: {
            _managed = false
            // if we already are in target page, acts on press
            if (Stack.currentPage()._pageName === pageName) {
                action()
                _managed = true
            }
        }
        onClicked: {
            if (_managed)
                return
            // we are not in target page: acts on click
            action()
        }

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

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
