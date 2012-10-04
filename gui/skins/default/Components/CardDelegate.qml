import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtExperience 1.0
import "../js/CardView.js" as CardViewScript


Item {
    id: itemDelegate

    property alias source: imageDelegate.source
    property alias label: textDelegate.text
    property int index: -1
    property variant view
    property alias moveAnimationRunning: defaultAnimation.running

    signal clicked
    signal removeAnimationFinished()

    width: bg.width
    height: bg.height
    onHeightChanged: itemDelegate.view.height = height // needed to correctly dimension the view

    Image { // placed here because the background must mask part of the image
        id: imageDelegate
        // the up-navigation is needed because images are referred to project
        // top folder
        anchors {
            fill: bg
            topMargin: bg.height / 100 * 1.65
            leftMargin: bg.width / 100 * 2.38
            rightMargin: bg.width / 100 * 2.86
            bottomMargin: bg.height / 100 * 16.17
        }
        source: ""
    }

    Image {
        id: icon
        anchors.fill: imageDelegate
        Rectangle {
            id: bgProfilePressed
            color: "black"
            opacity: 0.5
            visible: false
            anchors.fill: parent
        }
    }

    SvgImage {
        id: bg

        source: global.guiSettings.skin === GuiSettings.Clear ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_P.svg"
    }

    UbuntuLightText {
        id: textDelegate
        text: "prova microfono"
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" : "white"
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: bg.bottom
            bottomMargin: 10
            left: bg.left
            right: bg.right
        }
    }

    BeepingMouseArea {
        anchors.fill: parent
        onClicked: itemDelegate.clicked()
        onPressed: itemDelegate.view.currentPressed = index
        onReleased: itemDelegate.view.currentPressed = -1
    }

    states: [
        State {
            when: itemDelegate.view.currentPressed === index
            PropertyChanges {
                target: bg
                source: global.guiSettings.skin === GuiSettings.Clear ?
                            "../images/profiles/scheda_profili_P.svg" :
                            "../images/profiles/scheda_profili.svg"
            }
            PropertyChanges {
                target: textDelegate
                color: global.guiSettings.skin === GuiSettings.Clear ? "white" : "#434343"
            }
            PropertyChanges {
                target: bgProfilePressed
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
