import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
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
        anchors.fill: bg
        source: ""
    }

    SvgImage {
        id: bg

        source: global.guiSettings.skin === 0 ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_dark.svg"
    }

    UbuntuLightText {
        id: textDelegate
        text: "prova microfono"
        color: global.guiSettings.skin === 0 ? "#434343" : "white"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: bg.bottom
            bottomMargin: 10
            left: bg.left
            right: bg.right
        }
    }

    MouseArea {
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
                source: global.guiSettings.skin === 0 ?
                            "../images/profiles/scheda_profili_P.svg" :
                            "../images/profiles/scheda_profili_dark_P.svg"
            }
            PropertyChanges {
                target: textDelegate
                color: global.guiSettings.skin === 0 ? "white" : "#434343"
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
