import QtQuick 1.1


Item {
    id: menuItem
    height: 50
    width: 212

    property bool hasChild: true
    property int status: -1
    property string description: ""
    property string name: ""

    function statusVisible() {
        return menuItem.status > -1
    }

    Image {
        anchors.fill: parent
        z: 0
        id: background
        source: "common/btn_menu.png";
    }

    Item {
        anchors.fill: parent
        z: 1

        Image {
            visible: statusVisible()
            id: iconStatus
            source: (statusVisible() ? (menuItem.status === 1 ? "common/on.png" :"common/off.png") : "");
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        Text {
            id: text
            text: name
            font.family: semiBoldFont.name
            font.pixelSize: 14
            wrapMode: "WordWrap"
            anchors.left: statusVisible() ? iconStatus.right : parent.left
            anchors.leftMargin: statusVisible() ? 0 : 10
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: arrowRight.left
        }

        Image {
            visible: menuItem.hasChild
            id: arrowRight
            source: "common/freccia_dx.png"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
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
            anchors.left: statusVisible() ? iconStatus.right : parent.left
            anchors.leftMargin: statusVisible() ? 0 : 10
            verticalAlignment: Text.AlignBottom
        }
    }


    states: State {
        name: "selected"
        PropertyChanges { target: text; color: "#ffffff" }
        PropertyChanges { target: textDescription; color: "#ffffff" }
        PropertyChanges { target: arrowRight; source: "common/freccia_dxS.png" }
        PropertyChanges { target: background; source: "common/btn_menuS.png" }
    }
}

