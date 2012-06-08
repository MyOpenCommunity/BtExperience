import QtQuick 1.1


Item {
    id: menuItem
    height: background.height
    width: background.width

    property bool editable: false
    property string name
    property alias description: textDescription.text
    property alias boxInfoState: boxInfo.state
    property alias boxInfoText: boxInfoText.text
    property int status: -1
    property bool hasChild: false
    property alias backgroundImage: background.source

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)
    signal editCompleted()

    QtObject {
        id: privateProps

        function startEdit() {
            label.forceActiveFocus()
            label.openSoftwareInputPanel()
        }

        function editDone() {
            if (label.text !== menuItem.name) {
                menuItem.name = label.text
                menuItem.editCompleted()
            }
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
            return base + "menu_column_item_warning_led.svg" // TODO warning image is missing
    }

    SvgImage {
        anchors.fill: parent
        id: background
        source: "../images/common/menu_column_item_bg.svg";
    }


    Item {
        anchors.fill: parent

        SvgImage {
            id: iconStatus
            source: iconStatusImage()
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 2
            anchors.topMargin: menuItem.height / 100 * 18
            anchors.top: parent.top
        }

        TextInput {
            id: label
            text: menuItem.name
            activeFocusOnPress: false
            font.family: lightFont.name
            font.pixelSize: 14
            color:  "#2d2d2d"
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 9
            anchors.top: parent.top
            anchors.topMargin: menuItem.height / 100 * 16
            anchors.right: arrowRight.left
            onActiveFocusChanged: if (!activeFocus) { privateProps.editDone() }
        }

        Image {
            visible: menuItem.hasChild
            id: arrowRight
            source: "../images/common/menu_column_item_arrow.svg"
            anchors.right: parent.right
            anchors.rightMargin: menuItem.width / 100 * 3
            anchors.top: parent.top
            anchors.topMargin: menuItem.height / 100 * 24
        }

        Item {
            id: boxInfo
            visible: false
            anchors.top: label.bottom
            anchors.bottom: parent.bottom
            anchors.left: label.left
            width: 45

            Rectangle {
                id: boxInfoRect
                color: "#999"
                radius: 4
                height: 17
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    id: boxInfoText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
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

        Text {
            id: textDescription
            color: "#626262"
            font.family: regularFont.name
            wrapMode: Text.NoWrap
            font.pixelSize: 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: menuItem.height / 100 * 10
            anchors.top: label.bottom
            anchors.left: boxInfo.visible ? boxInfo.right : label.left
            anchors.leftMargin: boxInfo.visible ? 5 : 0
            verticalAlignment: Text.AlignBottom
        }
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onPressAndHold: if (menuItem.editable) { privateProps.startEdit() }
        onClicked: menuItem.clicked(menuItem)
        onPressed: menuItem.pressed(menuItem)
        onReleased: menuItem.released(menuItem)
    }

    states: [
        State {
            name: "selected"
            PropertyChanges { target: label; color: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_selected.svg" }
        },
        State {
            name: "pressed"
            when: mousearea.pressed
            PropertyChanges { target: label; color: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_pressed.svg" }
        }
    ]
}

