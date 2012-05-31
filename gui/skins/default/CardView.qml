import QtQuick 1.1

Item {
    id: cardView
    property variant model: undefined
    property Component delegate: undefined

    Component.onCompleted: {
        // compute the number of visible elements
        var widthExcludingArrows = cardView.width - prevArrow.width * 2
        var numDelegates = Math.floor(widthExcludingArrows / privateProps.largeDelegateWidth)
        // take delegate spacing into account (spacing is only between delegates)
        var spacingWidth = (numDelegates - 1) * privateProps.delegateSpacing
        if (widthExcludingArrows - numDelegates * privateProps.largeDelegateWidth > spacingWidth)
            privateProps.visibleElements = numDelegates
        else
            privateProps.visibleElements = numDelegates - 1

        if (model.count <= privateProps.visibleElements)
            cardView.state = "hiddenArrows"

    }

    QtObject {
        id: privateProps
        property int largeDelegateWidth: 175
        property int delegateSpacing: 10
        property int visibleElements: 1
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

        ListView {
            id: listView
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
            anchors.centerIn: parent

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

    Image {
        id: nextArrow
        source: "images/common/pager_arrow_next.svg"
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = listView.currentIndex + privateProps.visibleElements
                if (newPos <= model.count - 1) {
                    listView.positionViewAtIndex(newPos, ListView.Beginning)
                    listView.currentIndex = newPos
                }
            }
        }
    }

    Image {
        id: prevArrow
        source: "images/common/pager_arrow_previous.svg"
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = listView.currentIndex - privateProps.visibleElements
                if (newPos > 0) {
                    listView.positionViewAtIndex(newPos, ListView.Beginning)
                    listView.currentIndex = newPos
                }
                else {
                    listView.positionViewAtIndex(0, ListView.Beginning)
                    listView.currentIndex = 0
                }
            }
        }
    }

    states: State {
        name: "hiddenArrows"
        PropertyChanges {
            target: nextArrow
            visible: false
        }
        PropertyChanges {
            target: prevArrow
            visible: false
        }
    }
}
