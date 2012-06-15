import QtQuick 1.1
import "../js/CardView.js" as Script
// will contain all created delegates, assume we can index it from 0 to model.count
import "../js/CustomView.js" as Vars

Item {
    property int visibleElements: 3
    property int delegateSpacing: 10
    property variant model
    property Component delegate

    id: customView

    Connections {
        target: model
        onCountChanged: {
            console.log("Model count changed")
            clipView.modelReset()
        }
    }

    Image {
        id: prevArrow
        source: "../images/common/pager_arrow_previous.svg"
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            enabled: !Vars.dict[(clipView.currentIndex + 1) % model.count].moveAnimationRunning
            onClicked: clipView.decrementCurrentIndex()
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
        Item {
            property int currentIndex: -1
            property int currentPressed: -1

            function initDelegates() {
                for (var i = 0; i < visibleElements; ++i) {
                    var delegateX = (Script.listDelegateWidth + delegateSpacing) * i
                    Vars.dict[i] = delegate.createObject(clipView, {"x": delegateX, "y": clipView.y, "index": i, "view": clipView})
                }
                currentIndex = 0
            }

            function clearDelegates() {
                for (var d in Vars.dict) {
                    Vars.dict[d].destroy()
                }
            }

            function modelReset() {
                clearDelegates()
                initDelegates()
            }

            function moveDelegates(direction) {
                var factor = direction === Vars.DIR_LEFT ? 1 : -1
                for (var d in Vars.dict) {
                    Vars.dict[d].x += (Script.listDelegateWidth + delegateSpacing) * factor
                }
            }

            function removeDelegate(index) {
                var exitingDelegate = Vars.dict[index]
                exitingDelegate.removeAnimationFinished.connect(exitingDelegate.destroy)
                exitingDelegate.state = "remove"
            }

            function incrementCurrentIndex() {
                // 1. create the new delegate outside on the right
                var lastIndex = (currentIndex + visibleElements - 1) % model.count
                var newDelegateIndex = (lastIndex + 1) % model.count
                var newDelegateX = Vars.dict[lastIndex].x + Script.listDelegateWidth + delegateSpacing
                Vars.dict[newDelegateIndex] = delegate.createObject(clipView, {"x": newDelegateX, "y": clipView.y, "index": newDelegateIndex, "view": clipView})

                // 2. Remove and destroy the leftmost delegate
                removeDelegate(currentIndex)

                if (++currentIndex >= model.count)
                    currentIndex = 0
                moveDelegates(Vars.DIR_RIGHT)
            }

            function decrementCurrentIndex() {
                var newDelegateIndex = currentIndex - 1
                // wrap around, cannot use modulo for negative numbers
                if (newDelegateIndex < 0)
                    newDelegateIndex = model.count - 1

                var newDelegateX = Vars.dict[currentIndex].x - Script.listDelegateWidth - delegateSpacing
                Vars.dict[newDelegateIndex] = delegate.createObject(clipView, {"x": newDelegateX, "y": clipView.y, "index": newDelegateIndex, "view": clipView})

                var lastIndex = (currentIndex + visibleElements - 1) % model.count
                removeDelegate(lastIndex)

                if (--currentIndex < 0)
                    currentIndex = model.count - 1
                moveDelegates(Vars.DIR_LEFT)
            }

            id: clipView
            clip: true
            width: {
                var min = Math.min(visibleElements, model.count)
                return min * Script.listDelegateWidth + (min - 1) * delegateSpacing
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Image {
        id: nextArrow
        source: "../images/common/pager_arrow_next.svg"
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            enabled: !Vars.dict[(clipView.currentIndex + 1) % model.count].moveAnimationRunning
            onClicked: clipView.incrementCurrentIndex()
        }
    }

    Component.onCompleted: clipView.initDelegates()
}
