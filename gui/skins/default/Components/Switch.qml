import QtQuick 1.1
import Components 1.0


SvgImage {
    id: systemIcon

    property int status: 0 // 0 - closed, 1 - open
    property alias bgImage: systemIcon.source
    property alias leftImageBg: locked.source
    property alias leftImage: lockedTop.source
    property alias arrowImage: unlockedArrow.source
    property alias rightImageBg: unlocked.source
    property alias rightImage: unlockedTop.source

    signal clicked

    source: "../images/common/option_switch_background.svg"

    BeepingMouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: systemIcon.clicked()
    }

    SvgImage {
        id: locked

        source: "../images/common/button_switch_red.svg"

        anchors.left: parent.left

        SvgImage {
            id: lockedTop
            source: "../images/common/symbol_lock_close.svg"
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: pressedImage
        source: "../images/common/button_switch_p.svg"
        anchors.centerIn: locked
        visible: mouseArea.pressed
        z: 1
        opacity: 0.7
    }

    SvgImage {
        id: lockedArrow
        source: "../images/common/symbol_double-arrow.svg"
        anchors.centerIn: locked
        visible: false
        rotation: 180
    }

    SvgImage {
        id: unlocked

        source: "../images/common/button_switch_green.svg"

        visible: false
        anchors.right: parent.right

        SvgImage {
            id: unlockedTop
            source: "../images/common/symbol_lock_open.svg"
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: unlockedArrow
        source: "../images/common/symbol_double-arrow.svg"
        anchors.centerIn: unlocked
    }

    states: [
        State {
            name: "unlocked"
            when: status === 1
            PropertyChanges {
                target: locked
                visible: false
            }
            PropertyChanges {
                target: unlocked
                visible: true
            }
            PropertyChanges {
                target: lockedArrow
                visible: true
            }
            PropertyChanges {
                target: unlockedArrow
                visible: false
            }
            PropertyChanges { target: pressedImage; anchors.centerIn: unlocked }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges {
                target: locked
                visible: true
            }
            PropertyChanges {
                target: unlocked
                visible: false
            }
            PropertyChanges {
                target: lockedArrow
                visible: false
            }
            PropertyChanges {
                target: unlockedArrow
                visible: true
            }
            PropertyChanges { target: pressedImage; anchors.centerIn: locked }
        }
    ]
}
