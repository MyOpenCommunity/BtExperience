import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    property url defaultImage: ""
    property url pressedImage: ""
    property url selectedImage: ""
    property url defaultIcon: ""
    property url pressedIcon: ""
    property url selectedIcon: ""
    property url shadowImage: ""

    property alias text: label.text
    property alias font: label.font
    property alias textAnchors: label.anchors
    property alias horizontalAlignment: label.horizontalAlignment

    property bool enabled: true
    property int status: 0 // 0 - up, 1 - down

    signal clicked(variant mouse)

    source: defaultImage

    MouseArea {
        id: area
        anchors.fill: parent
        onClicked: bg.clicked(mouse)
        // in some cases I have to disable the button to not accept any input
        visible: bg.enabled
    }

    UbuntuLightText {
        id: label
        color: "black"
        anchors.centerIn: parent
        wrapMode: Text.WordWrap
    }

    SvgImage {
        id: icon
        anchors.centerIn: parent
        source: defaultIcon
    }

    SvgImage {
        id: shadow
        anchors {
            left: bg.left
            top: bg.bottom
            right: bg.right
        }
        source: shadowImage
    }

    // for the reasons behind normal state see ButtonThreeStates
    states: [
        State {
            name: "pressed"
            when: (area.pressed) && (status === 0)
            PropertyChanges { target: bg; source: pressedImage }
            PropertyChanges { target: icon; source: pressedIcon }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: label; color: "white" }
        },
        State {
            name: "selected"
            when: (status === 1)
            PropertyChanges { target: bg; source: selectedImage }
            PropertyChanges { target: icon; source: "" }
            PropertyChanges { target: label; text: "STOP" }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: bg; source: defaultImage }
            PropertyChanges { target: icon; source: defaultIcon }
            PropertyChanges { target: shadow; visible: true }
            PropertyChanges { target: label; text: "" }
        }
    ]
}
