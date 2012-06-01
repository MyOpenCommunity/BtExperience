import QtQuick 1.1

Item {
    id: cardView
    property variant model: undefined
    property Component delegate: undefined

    Component.onCompleted: {
        var elementColumns = Math.ceil(model.count / privateProps.rows)

        // compute the number of visible elements
        var widthExcludingArrows = cardView.width - prevArrow.width * 2
        var numColumns = Math.min(elementColumns, Math.floor(widthExcludingArrows / privateProps.delegateWidth))
        // take delegate spacing into account (spacing is only between delegates)
        var spacingWidth = (numColumns - 1) * privateProps.horizontalSpacing
        if (widthExcludingArrows - numColumns * privateProps.delegateWidth > spacingWidth)
            privateProps.visibleColumns = numColumns
        else
            privateProps.visibleColumns = numColumns - 1

        if (Math.ceil(model.count / privateProps.rows) <= privateProps.visibleColumns)
            cardView.state = "hiddenArrows"
    }

    QtObject {
        id: privateProps
        property int delegateWidth: 140
        property int horizontalSpacing: 40
        property int visibleColumns: 1
        property int rows: 2
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

        GridView {
            id: gridView
            property int currentPressed: -1

            model: cardView.model
            delegate: cardView.delegate
            flow: GridView.TopToBottom

            // 4 columns and 2 rows
            cellHeight: 140 + 22 + 7
            cellWidth: 180
            height: cellHeight * privateProps.rows
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
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = gridView.currentIndex + privateProps.visibleColumns * privateProps.rows
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
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newPos = gridView.currentIndex - privateProps.visibleColumns * privateProps.rows
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
        }
        PropertyChanges {
            target: prevArrow
            visible: false
        }
    }
}
