import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


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
        width: 175
        height: 20
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
        UbuntuLightText {
            id: labelText
            text: modelData
            font.pixelSize: 13
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: delegateBackground
        width: 175
        height: 244
        anchors.top: textDelegate.bottom
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
    }

    Image {
        id: imageDelegate
        width: 169
        height: 238
        anchors {
            bottom: delegateBackground.bottom
            bottomMargin: 5
            horizontalCenter: delegateBackground.horizontalCenter
        }
        source: users.selectRoomImage(modelData)
    }

    SvgImage {
        id: delegateShadow
        source: "../images/home/pager_shadow.svg"
        anchors {
            top: delegateBackground.bottom
            topMargin: 5
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
