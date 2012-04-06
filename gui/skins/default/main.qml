import QtQuick 1.1
import "js/Stack.js" as Stack
import Components 1.0

Item {
    id: container
    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }
    property alias animation: animationLoader
    property string animationType: "fade"


    Component.onCompleted: {
        Stack.container = container
        Stack.openPage("HomePage.qml")
    }

    Loader {
        id: animationLoader
        sourceComponent: {
            switch (container.animationType) {
            case "slide":
                return slideAnimationComponent
            case "fade":
                return fadeAnimationComponent
            default:
                console.log("Warning: unknown animation type!")
                return fadeAnimationComponent
            }
        }
    }

    Component {
        id: fadeAnimationComponent
        FadeAnimation {
        }
    }

    Component {
        id: slideAnimationComponent
        SlideAnimation {
        }
    }

    Connections {
        target: animationLoader.item
        onAnimationCompleted: Stack.changePageDone()
    }

    Connections {
        target: global
        onLastTimePressChanged: {
            //            console.log("last time press: " + global.lastTimePress)
        }
    }

    ScreenSaver {
        // TODO load the right screensaver depending on configuration
        screensaverFile: "ScreenSaverBouncingImage.qml"
    }
}
