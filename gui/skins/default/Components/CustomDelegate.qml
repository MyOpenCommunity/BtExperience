import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/CardView.js" as CardViewScript


Item {
    property alias source: imageDelegate.source
    property alias label: labelText.text
    property int index: -1
    property variant view
    property alias moveAnimationRunning: defaultAnimation.running

    signal clicked
    signal removeAnimationFinished()

    id: itemDelegate
    width: delegateBackground.width
    height: textDelegate.height + delegateBackground.height + delegateShadow.height + delegateShadow.anchors.topMargin
    onHeightChanged: itemDelegate.view.height = height

    Rectangle {
        id: delegateBackground
        width: CardViewScript.listDelegateWidth
        height: CardViewScript.listDelegateWidth / 100 * 139

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
    }

    Rectangle {
        id: textDelegate
        width: CardViewScript.listDelegateWidth
        height: CardViewScript.listDelegateWidth / 100 * 11
        anchors.top: delegateBackground.bottom
        color: Qt.rgba(230, 230, 230)
        opacity: 0.5
        UbuntuLightText {
            id: labelText
            font.pixelSize: CardViewScript.listDelegateWidth / 100 * 7
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }

    SvgImage {
        id: delegateShadow
        source: "../images/home/pager_shadow.svg"
        anchors {
            top: textDelegate.bottom
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
        onPressed: itemDelegate.view.currentPressed = index
        onReleased: itemDelegate.view.currentPressed = -1
    }

    states: [
        State {
            when: itemDelegate.ListView.view.currentPressed === index
            PropertyChanges {
                target: rectPressed
                visible: true
            }
        },
        State {
            name: "remove"
        }
    ]

    transitions:
        Transition {
            from: "*"
            to: "remove"
            SequentialAnimation {
                NumberAnimation { target: itemDelegate; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InSine }
                ScriptAction { script: itemDelegate.removeAnimationFinished() }
            }
        }

    Behavior on x {
        NumberAnimation { id: defaultAnimation; duration: 300; easing.type: Easing.InSine }
    }
}
