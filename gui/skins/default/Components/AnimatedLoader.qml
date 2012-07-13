import QtQuick 1.1

Item {
    id: itemLoader
    property variant item: undefined
    property alias duration: opacityanimation.duration
    height: 0

    function setComponent(component, properties) {
        privateObj.pendingComponent = component
        privateObj.pendingProperties = (properties === undefined ? {} : properties)
        if (item === undefined)
            privateObj.createComponent()
        else
            itemLoader.opacity = 0 // the createComponent is called after the opacity animation ends
    }

    QtObject {
        id: privateObj
        property variant pendingComponent  // contains the component to create
        property variant pendingProperties // contains the array of the pending component properties

        function opacityAnimationFinished() {
            if (privateObj.pendingComponent !== undefined) // we have a pending component to create
                createComponent()
        }

        function createComponent() {
            if (itemLoader.item !== undefined) // we have to destroy the old item
                itemLoader.item.destroy()

            itemLoader.opacity = 1
            itemLoader.item = privateObj.pendingComponent.createObject(itemLoader, privateObj.pendingProperties)
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

