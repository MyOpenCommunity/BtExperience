import QtQuick 1.1

Item {
    id: itemDelegate
    height: 50
    width: 212
    // TODO: showStatus & showRightArrow are not necessary if we can check for the
    // existance of isOn and componentFile properties from the model
    property bool showStatus: false
    property bool showRightArrow: true
    property bool showDescription: false
    signal clicked(int index)

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
            visible: itemDelegate.showStatus
            id: iconStatus
            source: (itemDelegate.showStatus === true ? (isOn === true ? "common/on.png" :"common/off.png") : "");
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
            anchors.left: itemDelegate.showStatus ? iconStatus.right : parent.left
            anchors.leftMargin: itemDelegate.showStatus ? 0 : 10
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: arrowRight.left
        }

        Image {
            visible: itemDelegate.showRightArrow && componentFile
            id: arrowRight
            source: "common/freccia_dx.png"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        Text {
            id: textDescription
            text: itemDelegate.showDescription ? description : ""
            font.family: lightFont.name
            wrapMode: Text.NoWrap
            font.pixelSize: 14
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.top: text.bottom
            anchors.left: itemDelegate.showStatus ? iconStatus.right : parent.left
            anchors.leftMargin: itemDelegate.showStatus ? 0 : 10
            verticalAlignment: Text.AlignBottom
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Avoid destroy and recreate the items if the element is already selected
            if (itemDelegate.ListView.isCurrentItem)
                return

            itemList.currentIndex = index
            itemDelegate.clicked(index)
        }
    }

    states: State {
        name: "selected"
        when: itemDelegate.ListView.isCurrentItem
        PropertyChanges { target: text; color: "#ffffff" }
        PropertyChanges { target: textDescription; color: "#ffffff" }
        PropertyChanges { target: arrowRight; source: "common/freccia_dxS.png" }
        PropertyChanges { target: background; source: "common/btn_menuS.png" }
    }
}

