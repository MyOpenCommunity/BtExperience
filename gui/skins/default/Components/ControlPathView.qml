import QtQuick 1.1
import Components.Text 1.0


PathView {
    id: control

    // defaults are related to home page
    property int x0FiveElements: control.width / 100 * 15
    property int x0ThreeElements: control.width / 100 * 20
    property int x1: control.width / 2
    property int x2FiveElements: control.width - x0FiveElements
    property int x2ThreeElements: control.width - x0ThreeElements
    property int y0: control.height / 100 * 55
    property int y1: control.height / 100 * 50
    property int y2: y0
    property alias prevArrowAnchors: prevArrow.anchors
    property alias nextArrowAnchors: nextArrow.anchors

    property int currentPressed: -1

    signal clicked(variant delegate)
    signal internalClick()

    delegate: PathViewDelegate {
        id: viewDelegate
        itemObject: control.model.getObject(index)
        z: PathView.elementZ
        scale: PathView.elementScale
        opacity: PathView.elementOpacity
        onDelegateClicked: {
            if (global.guiSettings.beep)
                global.beep()
            control.clicked(delegate)
        }

        Connections {
            target: control
            onInternalClick: viewDelegate.delegateClicked(viewDelegate.itemObject)
        }
    }

    path: Path {
        startX: firstSegment.x - 5
        startY: firstSegment.y
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 0 }
        PathLine {
            id: firstSegment
            x: control.model.count < 5 ? x0ThreeElements : x0FiveElements
            y: y0
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            x: x1
            y: y1
        }
        PathAttribute { name: "elementScale"; value: 1.0 }
        PathAttribute { name: "elementZ"; value: 1 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            id: lastSegment
            x: control.model.count < 5 ? x2ThreeElements : x2FiveElements
            y: y2
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            x: lastSegment.x + 5
            y: lastSegment.y
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 0 }
    }

    function visibleItems() {
        var result = control.model.count
        if (result <= 3)
            return 3
        if (result > 7)
            return 7
        return result
    }

    pathItemCount: control.visibleItems()
    highlightRangeMode: PathView.StrictlyEnforceRange
    // 4 and 6 cards are special cases; we need to change to 0.49 to make the 4th (6th)
    // card visible
    preferredHighlightBegin: (pathItemCount % 2) === 0 ? 0.49 : 0.5
    preferredHighlightEnd: (pathItemCount % 2) === 0 ? 0.49 : 0.5

    onFlickStarted: {
        privateProps.hasFlicked = true
        currentPressed = -1
    }
    onMovementEnded: {
        if (!privateProps.hasFlicked)
            internalClick()
        else
            privateProps.hasFlicked = false

        currentPressed = -1
    }

    SvgImage {
        id: prevArrow
        source: "../images/common/freccia_sx.svg"
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaSx
            anchors.fill: parent
            onClicked: control.incrementCurrentIndex()
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
            rightMargin: prevArrowAnchors.leftMargin
            verticalCenter: parent.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaDx
            anchors.fill: parent
            onClicked: control.decrementCurrentIndex()
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

    QtObject {
        id: privateProps
        property bool hasFlicked: false
    }
}
