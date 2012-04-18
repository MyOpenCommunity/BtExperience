import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


Item {
    id: container
    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }
    property alias animation: animationManager.animation
    property alias animationType: animationManager.type


    Component.onCompleted: {
        Stack.container = container
        Stack.openPage("HomePage.qml")
    }

    AnimationManager {
        id: animationManager
    }

    EventManager {
        anchors.fill: parent
        // the EventManager must show some pages on top of everything else:
        // let's make it very "high"
        z: 1000
    }
}
