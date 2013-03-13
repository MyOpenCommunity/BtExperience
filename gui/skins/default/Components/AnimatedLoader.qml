import QtQuick 1.1

Item {
    id: itemLoader
    property Item item: null
    property alias duration: opacityanimation.duration
    width: 0
    height: 0

    function setComponent(component, properties) {
        if (item === null && component === undefined) // nothing to do
            return

        privateObj.pendingComponent = component
        privateObj.pendingProperties = (properties === undefined ? {} : properties)
        if (item === null)
            privateObj.createComponent()
        else
            itemLoader.opacity = 0 // the createComponent is called after the opacity animation ends
    }

    function destroyComponent() {
        privateObj.pendingComponent = undefined
        privateObj.pendingProperties = undefined
        itemLoader.opacity = 0
        // Properly destroy the item; if someone outside relies on item to be
        // null after this function, we are breaking their assumptions.
        // Also, in createComponent() we need to check for null-ness anyway,
        // since at start the item is already null.
        itemLoader.item.destroy()
    }

    QtObject {
        id: privateObj
        property variant pendingComponent  // contains the component to create
        property variant pendingProperties // contains the array of the pending component properties

        function opacityAnimationFinished() {
            if (privateObj.pendingComponent !== undefined) // we have a pending component to create
                createComponent()
            if (itemLoader.opacity === 0) {
                itemLoader.height = 0
                itemLoader.width = 0
            }
        }

        function createComponent() {
            if (itemLoader.item !== null) // we have to destroy the old item
                itemLoader.item.destroy()

            itemLoader.opacity = 1
            itemLoader.item = privateObj.pendingComponent.createObject(itemLoader, privateObj.pendingProperties)
            itemLoader.width = item.width
            itemLoader.height = item.height
            privateObj.pendingComponent = undefined
            privateObj.pendingProperties = undefined
        }
    }

    Behavior on opacity {
        NumberAnimation {
            id: opacityanimation
            duration: 300
        }
    }

    Connections {
        target: opacityanimation
        onRunningChanged: {
            // the running property can change from true to false (when
            // we are at the end of the animation) or from false to true (when
            // we are at the start of the animation). We are interested in
            // the first case.
            if (opacityanimation.running)
                return
            privateObj.opacityAnimationFinished()
        }
    }
}

