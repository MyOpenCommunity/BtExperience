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
        anchors.fill: parent
        onClicked: systemIcon.clicked()
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
        }
    ]
}
