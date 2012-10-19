import QtQuick 1.1
import Components.Text 1.0


Item {
    id: control

    property int arrowsMargin: 10

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

    ControlPathViewInternal {
        id: pathView

        anchors.fill: parent
        onClicked: control.clicked(delegate)
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
            onClicked: pathView.incrementCurrentIndex()
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
            onClicked: pathView.decrementCurrentIndex()
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
