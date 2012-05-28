import QtQuick 1.1

Item {
    id: cardView
    property alias model: view.model
    property alias delegate: view.delegate

    Component.onCompleted: {
//        console.log("cardView.width: " + width)
//        console.log("real size: " + listViewSpace.modelCount() * 180)
        if (listViewSpace.modelCount() * 180 < cardView.width)
            cardView.state = "hiddenArrows"
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
            if ( count === undefined) {
                // our model property name
                count = model.size
                if (count === undefined) {
                    // stringlist name (effectively a JS array)
                    count = model.length
                }
            }
            return count
        }

        ListView {
            property int currentPressed: -1

            id: view
            orientation: ListView.Horizontal
            spacing: 2
            height: 300
            // Compute width to center the ListView delegates
            // TODO: the current formula is temporary workaround, it must be
            // removed once all the models expose a count property
            width: {
                var count = listViewSpace.modelCount()
                return count * 180 > listViewSpace.width ? listViewSpace.width : count * 180
            }

            clip: true
            anchors.centerIn: parent
            model: model

            onFlickStarted: currentPressed = -1
            onMovementEnded: currentPressed = -1
        }
    }

    Image {
        id: nextArrow
        source: "images/common/pager_arrow_next.svg"
        anchors {
            right: parent.right
            rightMargin: 2
            verticalCenter: parent.verticalCenter
        }
    }

    Image {
        id: prevArrow
        source: "images/common/pager_arrow_previous.svg"
        anchors {
            left: parent.left
            leftMargin: 2
            verticalCenter: parent.verticalCenter
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
