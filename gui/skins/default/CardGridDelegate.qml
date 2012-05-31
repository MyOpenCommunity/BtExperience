import QtQuick 1.1
import Components 1.0

Item {
    property alias source: imageDelegate.source
    property alias label: labelText.text
    property variant view: ListView.view === null ? GridView.view : ListView.view

    signal clicked

    id: itemDelegate
    width: delegateBackground.width
    height: delegateBackground.height + delegateShadow.height

    Rectangle {
        id: delegateBackground
        width: 140
        height: 140
        anchors.top: textDelegate.bottom
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
        border.color: "black"
        border.width: 1
    }

    Image {
        id: imageDelegate
        width: 140
        height: 140
        anchors.centerIn: delegateBackground
        source: users.selectRoomImage(modelData)

        Rectangle {
            id: textDelegate
            width: 140
            height: 16
            color: "white"
            anchors.top: parent.top
            opacity: 0.75
            Text {
                id: labelText
                font.family: regularFont.name
                font.pixelSize: 15
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }



    SvgImage {
        id: delegateShadow
        // TODO: change with pager_grid_shadow
        source: "images/home/pager_shadow.svg"
        anchors {
            top: delegateBackground.bottom
            topMargin: 5
            horizontalCenter: delegateBackground.horizontalCenter
        }
    }

    SvgImage {
        id: rectPressed
        source: "images/common/profilo_p.svg"
        visible: false
        anchors.fill: imageDelegate
    }

    MouseArea {
        anchors.fill: parent

        onClicked: itemDelegate.clicked()
        onPressed: view.currentPressed = index
        onReleased: view.currentPressed = -1
    }

    states: State {
        when: view.currentPressed === index
        PropertyChanges {
            target: rectPressed
            visible: true
        }
    }
}
