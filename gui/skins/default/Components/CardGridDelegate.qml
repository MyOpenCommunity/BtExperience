import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/CardView.js" as Script


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
        width: Script.gridDelegateWidth
        height: Script._gridCardHeight
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
        border.color: "black"
        border.width: 1
    }

    Image {
        id: imageDelegate
        width: Script.gridDelegateWidth
        height: Script._gridCardHeight
        anchors.centerIn: delegateBackground
        source: users.selectRoomImage(modelData)

        Rectangle {
            id: textDelegate
            width: parent.width
            height: 16
            color: "white"
            anchors.top: parent.top
            opacity: 0.75
            UbuntuLightText {
                id: labelText
                font.pixelSize: 15
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    SvgImage {
        id: delegateShadow
        source: "../images/common/pager_grid_shadow.svg"
        // this is not necessarily needed, but you must remember to change it
        // if the image ever changes size, so I'm leaving it here as a bookmark
        height: Script._gridShadowHeight
        anchors {
            top: delegateBackground.bottom
            horizontalCenter: delegateBackground.horizontalCenter
        }
    }

    SvgImage {
        id: rectPressed
        source: "../images/common/profilo_p.svg"
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
