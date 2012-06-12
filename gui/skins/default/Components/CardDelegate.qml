import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/CardView.js" as CardViewScript


Item {
    property alias source: imageDelegate.source
    property alias label: labelText.text
    property variant view: ListView.view === null ? GridView.view : ListView.view

    signal clicked

    id: itemDelegate
    width: delegateBackground.width
    height: delegateBackground.height + delegateShadow.height

    Rectangle {
        id: textDelegate
        width: CardViewScript.listDelegateWidth
        height: CardViewScript.listDelegateWidth / 100 * 11
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
        UbuntuLightText {
            id: labelText
            text: modelData
            font.pixelSize: CardViewScript.listDelegateWidth / 100 * 7
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: delegateBackground
        width: CardViewScript.listDelegateWidth
        height: CardViewScript.listDelegateWidth / 100 * 139
        anchors.top: textDelegate.bottom
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
    }

    Image {
        id: imageDelegate
        width: CardViewScript.listDelegateWidth / 100 * 97
        height: CardViewScript.listDelegateWidth / 100 * 136
        anchors {
            bottom: delegateBackground.bottom
            bottomMargin: CardViewScript.listDelegateWidth / 100 * 3
            horizontalCenter: delegateBackground.horizontalCenter
        }
        source: users.selectRoomImage(modelData)
    }

    SvgImage {
        id: delegateShadow
        source: "../images/home/pager_shadow.svg"
        anchors {
            top: delegateBackground.bottom
            topMargin: CardViewScript.listDelegateWidth / 100 * 3
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
