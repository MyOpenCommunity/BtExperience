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
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        Text {
            id: text
            text: name
            font.family: semiBoldFont.name
            font.pixelSize: 14
            wrapMode: "WordWrap"
            anchors.left: parent.left
            anchors.leftMargin: 19
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.right: arrowRight.left
        }

        Image {
            visible: menuItem.hasChild
            id: arrowRight
            source: "../images/common/menu_column_item_arrow.svg"
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 12
        }

        Text {
            id: textDescription
            text: description
            font.family: lightFont.name
            wrapMode: Text.NoWrap
            font.pixelSize: 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
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

