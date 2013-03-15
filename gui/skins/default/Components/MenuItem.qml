import QtQuick 1.1
import Components.Text 1.0


Item {
    id: menuItem

    height: background.height
    width: background.width

    // Use this property instead of settings the state. This is required because
    // there are tree states: the default "", "pressed" and "selected". When the item
    // is in the logical selected status, if the user clicks on the item we want
    // to pass in the pressed status. For how the qml states works, when the user
    // releases the clicked item, the status of the item will go in the default status,
    // even if the starting state is the selected one. To avoid this behaviour, we
    // expose the property isSelected and "block" the use of the states from the
    // external of the item.
    property bool isSelected: false

    property bool editable: false
    property string name
    property alias description: textDescription.text
    property alias boxInfoState: boxInfo.state
    property alias boxInfoText: boxInfoText.text
    property int status: -1
    property bool hasChild: false
    property alias backgroundImage: background.source
    property bool enabled: true

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)
    signal touched(variant itemTouched)
    signal editCompleted()

    // 'virtual' function to reimplement pressAndHold behaviour in derived components
    function startEdit() {
        editMenuItem()
    }

    // This function actually starts menu item editing
    function editMenuItem() {
        labelLoader.sourceComponent = labelInputComponent
        labelLoader.item.forceActiveFocus()
        labelLoader.item.openSoftwareInputPanel()
    }

    QtObject {
        id: privateProps

        function editDone() {
            if (labelLoader.item.text !== menuItem.name) {
                menuItem.name = labelLoader.item.text
                menuItem.editCompleted()
            }
            labelLoader.sourceComponent = labelComponent
        }
    }

    function statusVisible() {
        return menuItem.status > -1
    }

    function iconStatusImage() {
        if (!statusVisible())
            return ""
        var base = "../images/common/"
        if (menuItem.status === 0)
            return base + "menu_column_item_inactive_led.svg"
        else if (menuItem.status === 1)
            return base + "menu_column_item_active_led.svg"
        else if (menuItem.status === 2)
            return base + "menu_column_item_warning_led.svg"
        else if (menuItem.status === 3)
            return base + "menu_column_item_alarm_led.svg"
        else if (menuItem.status === 4)
            return base + "menu_column_item_disabled_led.svg"
    }

    SvgImage {
        anchors.fill: parent
        id: background
        source: "../images/common/menu_column_item_bg.svg";
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: menuItem.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    SvgImage {
        id: iconStatus

        source: iconStatusImage()
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 18
            left: parent.left
            leftMargin: background.width / 100 * 2
        }
    }

    Loader {
        id: labelLoader

        property color textColor: "#2d2d2d"
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 16
            left: parent.left
            leftMargin: background.width / 100 * 9
            right: arrowRight.left
        }
        sourceComponent: labelComponent
    }

    Component {
        id: labelInputComponent
        UbuntuMediumTextInput {
            text: menuItem.name
            activeFocusOnPress: false
            font.pixelSize: 15
            color: labelLoader.textColor
            onActiveFocusChanged: if (!activeFocus) { privateProps.editDone() }
        }
    }

    Component {
        id: labelComponent
        UbuntuMediumText {
            text: menuItem.name
            font.pixelSize: 15
            color:  labelLoader.textColor
            elide: Text.ElideRight
        }
    }

    SvgImage {
        id: arrowRight

        visible: menuItem.hasChild
        source: "../images/common/menu_column_item_arrow.svg"
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 24
            right: parent.right
            rightMargin: background.width / 100 * 3
        }
    }

    Item {
        id: boxInfo

        width: 45
        visible: false
        anchors {
            top: labelLoader.bottom
            bottom: parent.bottom
            left: labelLoader.left
        }

        Rectangle {
            id: boxInfoRect
            color: "#999"
            radius: 4
            height: 17
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right

            UbuntuLightText {
                id: boxInfoText
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 15
            }
        }

        states: [
            State {
                name: "info"
                PropertyChanges { target: boxInfoRect; color: "#999999" }
                PropertyChanges { target: boxInfo; visible: true }

            },
            State {
                name: "warning"
                PropertyChanges { target: boxInfoRect; color: "#ed1b35" }
                PropertyChanges { target: boxInfo; visible: true }
            }
        ]
    }

    UbuntuLightText {
        id: textDescription

        color: "#626262"
        wrapMode: Text.NoWrap
        font.pixelSize: 15
        verticalAlignment: Text.AlignBottom
        anchors {
            top: labelLoader.bottom
            bottom: parent.bottom
            bottomMargin: background.height / 100 * 10
            left: boxInfo.visible ? boxInfo.right : labelLoader.left
            leftMargin: boxInfo.visible ? 5 : 0
        }
    }

    BeepingMouseArea {
        id: mousearea
        anchors.fill: parent
        pressAndHoldEnabled: menuItem.editable
        onHeld: if (menuItem.editable) { startEdit() }
        onClicked: menuItem.clicked(menuItem)
        onPressed: {
            touchTimer.restart()
            menuItem.pressed(menuItem)
        }
        onReleased: menuItem.released(menuItem)

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: menuItem.touched(menuItem)
        }
    }


    onStateChanged: {
        if (state === "")
            return

        for (var i = 0; i < states.length; ++i)
            if (state === states[i].name)
                return

        console.log("Warning: the state -> " + state + " <- is not allowed!")
    }

    states: [
        State {
            // Designed for internal use, not set from the extern of MenuItem. See comment on isSelected
            name: "_selected"
            when: isSelected && !mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_selected.svg" }
        },
        State {
            // Designed for internal use, not set from the extern of MenuItem. See comment on isSelected
            name: "_pressed"
            when: mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_pressed.svg" }
        }
    ]
}

