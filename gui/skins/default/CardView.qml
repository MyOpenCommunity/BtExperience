import QtQuick 1.1

Item {
    property alias model: view.model
    property alias delegate: view.delegate

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
            property int currentPressed: -1

            id: view
            orientation: ListView.Horizontal
            spacing: 2
            height: 300
            // Compute width to center the ListView delegates
            // TODO: the current formula is temporary workaround, it must be
            // removed once all the models expose a count property
            width: {
                // QML property name
                var width = model.count
                if ( width === undefined) {
                    // our model property name
                    width = model.size
                    if (width === undefined) {
                        // stringlist name (effectively a JS array)
                        width = model.length
                    }
                }
                return width * 180 > listViewSpace.width ? listViewSpace.width : width * 180
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
}
