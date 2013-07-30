import QtQuick 1.1
import Components.Text 1.0


Item {
    id: control

    property int arrowsMargin: 10
    property int pathviewId: 0
    property int offset_diff: 0

    property alias x0FiveElements: pathView.x0FiveElements
    property alias x0ThreeElements: pathView.x0ThreeElements
    property alias x1: pathView.x1
    property alias x2FiveElements: pathView.x2FiveElements
    property alias x2ThreeElements: pathView.x2ThreeElements
    property alias y0: pathView.y0
    property alias y1: pathView.y1
    property alias y2: pathView.y2
    property alias pathOffset: pathView.pathOffset
    property alias model: pathView.model

    signal clicked(variant delegate)

    Component.onCompleted: {
        offsetBehavior.enabled = false
        pathView.offset = global.getPathviewOffset(pathviewId)
        offsetBehavior.enabled = true
    }

    ControlPathViewInternal {
        id: pathView

        anchors.fill: parent
        onClicked: control.clicked(delegate)

        onOffsetChanged: {
            // remove pressed status when scrolling cards
            offset_diff = Math.abs(global.getPathviewOffset(pathviewId) - Math.round(offset))
            if ((offset_diff > 0 ) && (offset_diff < model.count )){
                currentPressed = -1
            }
            if (offsetBehavior.enabled)
                global.setPathviewOffset(pathviewId, Math.round(offset))
        }

        Behavior on offset {
            id: offsetBehavior
            NumberAnimation { duration: 300 }
        }
    }

    SvgImage {
        id: prevArrow
        source: "../images/common/freccia_sx.svg"
        anchors {
            left: parent.left
            leftMargin: control.arrowsMargin
            verticalCenter: parent.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaSx
            anchors.fill: parent
            onClicked: {
                if (pathView.offset === Math.round(pathView.offset))
                    pathView.offset -= 1
            }
        }

        states: [
            State {
                name: "pressed"
                when: mouseAreaSx.pressed === true
                PropertyChanges {
                    target: prevArrow
                    source: "../images/common/freccia_sx_P.svg"
                }
            }
        ]
    }

    SvgImage {
        id: nextArrow
        source: "../images/common/freccia_dx.svg"
        anchors {
            right: parent.right
            rightMargin: control.arrowsMargin
            verticalCenter: parent.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaDx
            anchors.fill: parent
            onClicked: {
                if (pathView.offset === Math.round(pathView.offset))
                    pathView.offset += 1
            }
        }

        states: [
            State {
                name: "pressed"
                when: mouseAreaDx.pressed === true
                PropertyChanges {
                    target: nextArrow
                    source: "../images/common/freccia_dx_P.svg"
                }
            }
        ]
    }
}
