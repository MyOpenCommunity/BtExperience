import QtQuick 1.1
import "js/Stack.js" as Stack


Item {
    id: container
    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }
    property alias animation: animationLoader

    Component.onCompleted: {
        Stack.container = container
        Stack.openPage("HomePage.qml")
    }

    Loader {
        id: animationLoader
        source: "Components/FadeAnimation.qml"
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

}
