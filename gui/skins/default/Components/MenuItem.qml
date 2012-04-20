import QtQuick 1.1


Item {
    id: menuItem
    height: background.height
    width: background.width

    property string name: ""
    property string description: ""
    property int status: -1
    property bool hasChild: false

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)

    function statusVisible() {
        return menuItem.status > -1
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
            source: (statusVisible() ? (menuItem.status === 1 ? "../images/common/menu_column_item_active_led.svg" :"../images/common/menu_column_item_inactive_led.svg") : "");
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 2
            anchors.topMargin: menuItem.height / 100 * 18
            anchors.top: parent.top
        }

        Text {
            id: text
            text: name
            font.family: semiBoldFont.name
            font.pixelSize: 14
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

        Text {
            id: textDescription
            text: description
            font.family: lightFont.name
            wrapMode: Text.NoWrap
            font.pixelSize: 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: menuItem.height / 100 * 10
            anchors.top: text.bottom
            anchors.left: text.left
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

