import QtQuick 1.1
import "Stack.js" as Stack


Item {
    id: container
    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: main_width / 1024; yScale: main_height / 600 }
    property alias animation: animationLoader

    Component.onCompleted: {
        Stack.container = container
        Stack.openPage("HomePage.qml")
    }

    Loader {
        id: animationLoader
        source: "FadeAnimation.qml"
    }

    Connections {
        target: animationLoader.item
        onAnimationCompleted: Stack.changePageDone()
    }
}
