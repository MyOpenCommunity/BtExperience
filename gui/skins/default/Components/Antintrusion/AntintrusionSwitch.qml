import QtQuick 1.1
import Components 1.0


SvgImage {
    id: systemIcon

    property int status: 0 // 0 - closed, 1 - open

    signal clicked

    source: "../../images/common/option_switch_background.svg"

    anchors.right: parent.right
    anchors.rightMargin: width / 100 * 10
    anchors.verticalCenter: parent.verticalCenter

    MouseArea {
        anchors.fill: parent
        onClicked: systemIcon.clicked()
    }

    SvgImage {
        id: locked

        source: "../../images/common/button_switch_red.svg"

        visible: true
        anchors.left: parent.left

        SvgImage {
            source: "../../images/common/symbol_lock_close.svg"
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: lockedArrow
        source: "../../images/common/symbol_double-arrow.svg"
        anchors.centerIn: locked
        visible: false
        rotation: 180
    }

    SvgImage {
        id: unlocked

        source: "../../images/common/button_switch_green.svg"

        visible: false
        anchors.right: parent.right

        SvgImage {
            source: "../../images/common/symbol_lock_open.svg"
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: unlockedArrow
        source: "../../images/common/symbol_double-arrow.svg"
        anchors.centerIn: unlocked
        visible: true
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
