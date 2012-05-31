import QtQuick 1.1

Item {
    id: cardView
    property variant model: undefined
    property Component delegate: undefined

    Component.onCompleted: {
        if (listViewSpace.modelCount() >= 7) {
            viewLoader.sourceComponent = gridView
            if (listViewSpace.modelCount() / 2 * 180 < cardView.width)
                cardView.state = "hiddenArrows"
        }
        else {
            viewLoader.sourceComponent = listView
            if (listViewSpace.modelCount() * 180 < cardView.width)
                cardView.state = "hiddenArrows"
        }
    }

    QtObject {
        id: privateProps
        property int largeDelegateWidth: 175
        property int delegateSpacing: 10
    }

    Component {
        id: listView
        ListView {
            property int currentPressed: -1

            orientation: ListView.Horizontal
            interactive: false
            spacing: privateProps.delegateSpacing
            height: 300

            // Compute width to center the ListView delegates
            // TODO: the current formula is temporary workaround, it must be
            // removed once all the models expose a count property
            width: {
                var count = listViewSpace.modelCount()
                return count * privateProps.largeDelegateWidth > listViewSpace.width ?
                            (count - 1) * privateProps.largeDelegateWidth + (count - 2) * privateProps.delegateSpacing:
                            count * privateProps.largeDelegateWidth + (count - 1) * privateProps.delegateSpacing
            }

            clip: true
            model: cardView.model
            delegate: cardView.delegate

            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1
        }
    }

    Component {
        id: gridView
        GridView {
            property int currentPressed: -1

            model: cardView.model
            delegate: cardView.delegate
            flow: GridView.TopToBottom

            // 4 columns and 2 rows
            height: 300 * 2
            width: listViewSpace.width
            cellHeight: 300
            cellWidth: 180

            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1
        }
    }

    Item {
        id: listViewSpace
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: prevArrow.right
            leftMargin: 2
            right: nextArrow.left
            rightMargin: 2
        }

        function modelCount() {
            // QML property name
            var count = model.count
            if (count === undefined) {
                // our model property name
                count = model.size
            }
            return count
        }

        Loader {
            id: viewLoader
            anchors.centerIn: parent
        }
    }

    Image {
        id: nextArrow
        source: "images/common/pager_arrow_next.svg"
        anchors {
            right: parent.right
            rightMargin: 20
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = Math.min(view.currentIndex + 5, listViewSpace.modelCount() - 1)
                view.positionViewAtIndex(newPos, ListView.Beginning)
                view.currentIndex = newPos
            }
        }
    }

    Image {
        id: prevArrow
        source: "images/common/pager_arrow_previous.svg"
        anchors {
            left: parent.left
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = Math.max(view.currentIndex - 5, 0)
                view.positionViewAtIndex(newPos, ListView.End)
                view.currentIndex = newPos
            }
        }
    }

    states: State {
        name: "hiddenArrows"
        PropertyChanges {
            target: nextArrow
            visible: false
            width: 0
        }
        PropertyChanges {
            target: prevArrow
            visible: false
            width: 0
        }
    }
}
