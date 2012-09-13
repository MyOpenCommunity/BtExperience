import QtQuick 1.1
import Components.Text 1.0


PathView {
    id: control

    // defaults are related to home page
    property int x0FiveElements: 100
    property int x0ThreeElements: 160
    property int x1: 370
    property int x2FiveElements: 640
    property int x2ThreeElements: 580
    property int y0: 220
    property int y1: 200
    property int y2: y0

    property int currentPressed: -1

    signal clicked(variant delegate)

    delegate: PathViewDelegate {
        itemObject: control.model.getObject(index)
        z: PathView.elementZ
        scale: PathView.elementScale
        onDelegateClicked: control.clicked(delegate)
    }

    path: Path {
        startX: control.model.count < 5 ? x0ThreeElements : x0FiveElements
        startY: y0
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathLine {
            x: x1
            y: y1
        }
        PathAttribute { name: "elementScale"; value: 1.0 }
        PathAttribute { name: "elementZ"; value: 1 }
        PathLine {
            x: control.model.count < 5 ? x2ThreeElements : x2FiveElements
            y: y2
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
    }

    pathItemCount: control.model.count < 5 ? 3 : 5
    highlightRangeMode: PathView.StrictlyEnforceRange
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    onFlickStarted: currentPressed = -1
    onMovementEnded: currentPressed = -1

    SvgImage {
        id: prevArrow
        source: "../images/common/freccia_sx.svg"
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: mouseAreaSx
            anchors.fill: parent
            onClicked: control.decrementCurrentIndex()
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
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: mouseAreaDx
            anchors.fill: parent
            onClicked: control.incrementCurrentIndex()
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
