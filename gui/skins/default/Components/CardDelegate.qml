import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import BtExperience 1.0

Item {
    id: itemDelegate

    property alias source: imageDelegate.source
    property alias label: textDelegate.text
    property int index: -1
    property variant view
    property alias moveAnimationRunning: defaultAnimation.running

    signal clicked
    signal removeAnimationFinished()

    width: cardShadow.width
    height: cardShadow.height
    onHeightChanged: itemDelegate.view.height = height // needed to correctly dimension the view

    Image { // placed here because the background must mask part of the image
        id: imageDelegate
        // the up-navigation is needed because images are referred to project
        // top folder
        anchors {
            fill: bg
            topMargin: Math.round(bg.height / 100 * 1.65)
            leftMargin: Math.round(bg.width / 100 * 2.38)
            rightMargin: Math.round(bg.width / 100 * 2.86)
            bottomMargin: Math.round(bg.height / 100 * 16.17)
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
        anchors.centerIn: parent

        source: homeProperties.skin === HomeProperties.Clear ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_P.svg"
    }

    BorderImage {
        id: cardShadow
        source: "../images/profiles/card_shadow.png"
        width: 238
        height: 331
        border { left: 24; top: 22; right: 24; bottom: 22 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    UbuntuLightText {
        id: textDelegate
        text: "prova microfono"
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" : "white"
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
                source: homeProperties.skin === HomeProperties.Clear ?
                            "../images/profiles/scheda_profili_P.svg" :
                            "../images/profiles/scheda_profili.svg"
            }
            PropertyChanges {
                target: textDelegate
                color: homeProperties.skin === HomeProperties.Clear ? "white" : "#434343"
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
