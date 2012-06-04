import QtQuick 1.1
import Components 1.0
import "js/MainContainer.js" as Container
import "js/Stack.js" as Stack


Item {
    id: container
    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }
    property alias animation: animationManager.animation
    property alias animationType: animationManager.type
    property alias ubuntuLight: ubuntuLightLoader
    property alias ubuntuMedium: ubuntuMediumLoader


    Component.onCompleted: {
        Container.mainContainer = container
        // We need to update the reference in Stack because it includes MainContainer
        // but it doesn't get the updates to it. Seems like that Qt.include()
        // in a JS file operates a literal inclusion, not a real variable
        // sharing
        Stack.mainContainer = container
        Stack.openPage("HomePage.qml")
    }

    FontLoader {
        id: ubuntuLightLoader
        source: "Ubuntu-L.ttf"
    }

    FontLoader {
        id: ubuntuMediumLoader
        source: "Ubuntu-M.ttf"
    }

    AnimationManager {
        id: animationManager
    }

    EventManager {
        anchors.fill: parent
        transform: Scale { origin.x: 0; origin.y: 0; xScale: 1024 / global.mainWidth; yScale: 600 / global.mainHeight }
        // the EventManager must show some pages on top of everything else:
        // let's make it very "high"
        z: 1000
    }
}
