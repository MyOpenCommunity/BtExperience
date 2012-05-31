import QtQuick 1.1

Item {
    id: cardView
    property variant model: undefined
    property Component delegate: undefined

    Component.onCompleted: {
        console.log("Enter")
        var numRows = 3
        var elementColumns = Math.ceil(model.count / numRows)

        // compute the number of visible elements
        var widthExcludingArrows = cardView.width - (prevArrow.width + 20) * 2
        console.log("PING")
        var numColumns = Math.min(elementColumns, Math.floor(widthExcludingArrows / privateProps.delegateWidth))
        // take delegate spacing into account (spacing is only between delegates)
        var spacingWidth = (numColumns - 1) * privateProps.horizontalSpacing
        console.log("widthExcludingArrows, numDelegates, spacingWidth: " + widthExcludingArrows + ","+ numColumns + ","+ spacingWidth)
        if (widthExcludingArrows - numColumns * privateProps.delegateWidth > spacingWidth)
            privateProps.visibleColumns = numColumns
        else
            privateProps.visibleColumns = numColumns - 1

        console.log("visibleColumns: " + privateProps.visibleColumns)
        if (Math.ceil(model.count / numRows) <= privateProps.visibleColumns)
            cardView.state = "hiddenArrows"
        console.log("PONG")
    }

    QtObject {
        id: privateProps
        property int delegateWidth: 140
        property int horizontalSpacing: 40
        property int visibleColumns: 1
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

        GridView {
            id: gridView
            property int currentPressed: -1

            model: cardView.model
            delegate: cardView.delegate
            flow: GridView.TopToBottom

            // 4 columns and 2 rows
            cellHeight: 140 + 22 + 7
            cellWidth: 180
            height: cellHeight * 3
            width: privateProps.visibleColumns * privateProps.delegateWidth +
                   (privateProps.visibleColumns - 1) * privateProps.horizontalSpacing
            anchors.centerIn: parent

            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1
            interactive: false
            clip: true

            // Needed to leave empty space at the end of the list if there are
            // not enough elements when calling positionViewAtIndex()
            preferredHighlightBegin: 0
            preferredHighlightEnd: privateProps.delegateWidth
            highlightRangeMode: GridView.StrictlyEnforceRange
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
                var newPos = gridView.currentIndex + privateProps.visibleColumns * 3
                if (newPos <= model.count - 1) {
                    gridView.positionViewAtIndex(newPos, GridView.Beginning)
                    gridView.currentIndex = newPos
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
                var newPos = gridView.currentIndex - privateProps.visibleColumns * 3
                console.log("newPos, model.count: " + newPos +","+model.count)
                if (newPos > 0) {
                    gridView.positionViewAtIndex(newPos, GridView.Beginning)
                    gridView.currentIndex = newPos
                }
                else {
                    gridView.positionViewAtIndex(0, GridView.Beginning)
                    gridView.currentIndex = 0
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
