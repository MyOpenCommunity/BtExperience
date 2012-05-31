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
            var count = model.count
            // compute the number of visible elements
            var numDelegates = Math.floor(cardView.width / privateProps.largeDelegateWidth)
            // take delegate spacing into account (spacing is only between delegates)
            var spacingWidth = (numDelegates - 1) * privateProps.delegateSpacing
            if (cardView.width - numDelegates * privateProps.largeDelegateWidth > spacingWidth)
                privateProps.visibleElements = numDelegates
            else
                privateProps.visibleElements = numDelegates - 1

            if (count <= privateProps.visibleElements)
                cardView.state = "hiddenArrows"
        }
    }

    QtObject {
        id: privateProps
        property int largeDelegateWidth: 175
        property int delegateSpacing: 10
        property int visibleElements: 1
    }

    Component {
        id: listView
        ListView {
            property int currentPressed: -1

            orientation: ListView.Horizontal
            interactive: false
            spacing: privateProps.delegateSpacing
            height: 300
            // Compute width to center the list view
            width: {
                var min = Math.min(privateProps.visibleElements, model.count)
                return min * privateProps.largeDelegateWidth + (min - 1) * privateProps.delegateSpacing
            }

            clip: true
            model: cardView.model
            delegate: cardView.delegate

            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1

            // Needed to leave empty space at the end of the list if there are
            // not enough elements when calling positionViewAtIndex()
            preferredHighlightBegin: 0
            preferredHighlightEnd: privateProps.largeDelegateWidth
            highlightRangeMode: ListView.StrictlyEnforceRange
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
                var newPos = viewLoader.item.currentIndex + privateProps.visibleElements
                if (newPos <= model.count - 1) {
                    viewLoader.item.positionViewAtIndex(newPos, ListView.Beginning)
                    viewLoader.item.currentIndex = newPos
                }
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
                var newPos = viewLoader.item.currentIndex - privateProps.visibleElements
                if (newPos > 0) {
                    viewLoader.item.positionViewAtIndex(newPos, ListView.Beginning)
                    viewLoader.item.currentIndex = newPos
                }
                else {
                    viewLoader.item.positionViewAtIndex(0, ListView.Beginning)
                    viewLoader.item.currentIndex = 0
                }
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
