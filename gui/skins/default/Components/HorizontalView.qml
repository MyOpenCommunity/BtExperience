import QtQuick 1.1

Item {
    id: horizontalView
    property QtObject model: null
    property int delegateWidth: 140
    property int selectedIndex: 0
    property Component delegate: null

    SvgImage {
        id: prevArrow
        source: "../images/common/freccia_sx.svg"
        visible: horizontalView.model.count > 5
        anchors {
            left: parent.left
            leftMargin: parent.width / 100
            verticalCenter: loader.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaSx
            anchors.fill: parent
            onClicked: {
                if (loader.item.offset === Math.round(loader.item.offset))
                    loader.item.offset -= 1
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
        visible: horizontalView.model.count > 5
        source: "../images/common/freccia_dx.svg"
        anchors {
            right: parent.right
            rightMargin: parent.width / 100
            verticalCenter: loader.verticalCenter
        }

        BeepingMouseArea {
            id: mouseAreaDx
            anchors.fill: parent
            onClicked: {
                if (loader.item.offset === Math.round(loader.item.offset))
                    loader.item.offset += 1
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

    Loader {
        id: loader
        anchors {
            left: prevArrow.right
            right: nextArrow.left
        }
        height: parent.height
        sourceComponent: horizontalView.model.count > 5 ? manyElements : fewElements
    }

    Component {
        id: manyElements
        PathView {
            id: roomView
            anchors.fill: parent
            pathItemCount: 5
            clip: true
            model: horizontalView.model
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            delegate: horizontalView.delegate

            path: Path {
                id: pathDefinition
                // here we can't use roomView.width directly because it doesn't work
                // as expected for unknown reasons.
                // We need a fixed number, we will assign it later on.
                property int pathWidth: 500
                startX: 0
                startY: roomView.height / 2
                PathLine { x: parent.width; y: roomView.height / 2}

            }

            Behavior on offset {
                id: offsetBehavior
                NumberAnimation { duration: 300 }
            }
        }
    }

    Component {
        id: fewElements
        Item {
            clip: true
            anchors.fill: parent
            ListView {
                id: listView
                orientation: ListView.Horizontal

                interactive: false
                model: horizontalView.model
                anchors.horizontalCenter: parent.horizontalCenter
                width: delegateWidth * model.count
                delegate: horizontalView.delegate
            }
        }
    }
}
