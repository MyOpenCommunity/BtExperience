import QtQuick 1.1

Loader {
    id: itemLoader

    QtObject {
        id: privateProps
        property variant pendingComponent: undefined

        function showComponent() {
            opacity = 1
            sourceComponent = privateProps.pendingComponent
            privateProps.pendingComponent = undefined
        }
    }


    function changeComponent(newComponent) {
        privateProps.pendingComponent = newComponent
        if (sourceComponent !== null)
            opacity = 0 // implictly use the Connections object
        else
            privateProps.showComponent()
    }

    Connections {
        target: opacityanimation
        onRunningChanged: {
            if (opacityanimation.running) // at the end of the animation
                return
            // if there is a pending component, we show it
            if (privateProps.pendingComponent !== undefined)
                privateProps.showComponent()
        }
    }

    Behavior on opacity {
        NumberAnimation {
            id: opacityanimation
            duration: 300
        }
    }
}
