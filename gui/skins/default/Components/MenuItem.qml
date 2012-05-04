import QtQuick 1.1


Item {
    id: menuItem
    height: background.height
    width: background.width

    property alias name: text.text
    property alias description: textDescription.text
    property alias boxInfoState: boxInfo.state
    property alias boxInfoText: boxInfoText.text
    property int status: -1
    property bool hasChild: false

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)

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

        Text {
            id: text
            font.family: lightFont.name
            font.pixelSize: 14
            color:  "#2d2d2d"
            font.bold: true
            wrapMode: "WordWrap"
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 9
            anchors.top: parent.top
            anchors.topMargin: menuItem.height / 100 * 16
            anchors.right: arrowRight.left
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
            anchors.top: text.bottom
            anchors.bottom: parent.bottom
            anchors.left: text.left
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
            anchors.top: text.bottom
            anchors.left: boxInfo.visible ? boxInfo.right : text.left
            anchors.leftMargin: boxInfo.visible ? 5 : 0
            verticalAlignment: Text.AlignBottom
        }
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: menuItem.clicked(menuItem)
        onPressed: menuItem.pressed(menuItem)
        onReleased: menuItem.released(menuItem)
    }

    states: [
        State {
            name: "selected"
            PropertyChanges { target: text; color: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_selected.svg" }
        },
        State {
            name: "pressed"
            when: mousearea.pressed
            PropertyChanges { target: text; color: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_pressed.svg" }
        }
    ]
}

