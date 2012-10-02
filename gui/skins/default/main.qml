import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "js/MainContainer.js" as Container
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManagerContainer


Item {
    id: container

    property alias animation: animationManager.animation
    property alias animationType: animationManager.type
    property alias ubuntuLight: ubuntuLightLoader
    property alias ubuntuMedium: ubuntuMediumLoader

    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }

    Component.onCompleted: {
        global.initAudio()

        Container.mainContainer = container
        EventManagerContainer.eventManager = eventManagerId
        // We need to update the reference in Stack because it includes MainContainer
        // but it doesn't get the updates to it, because in QtQuick 1.1 Qt.include()
        // in a JS file operates a literal inclusion, not a real variable
        // sharing
        // http://qt-project.org/forums/viewthread/18372
        Stack.mainContainer = container
        Stack.pushPage("HomePage.qml")
    }

    FontLoader {
        id: ubuntuLightLoader
        source: "Components/Text/Ubuntu-L.ttf"
    }

    FontLoader {
        id: ubuntuMediumLoader
        source: "Components/Text/Ubuntu-M.ttf"
    }

    AnimationManager {
        id: animationManager
    }

    EventManager {
        id: eventManagerId
        anchors.fill: parent
        transform: Scale { origin.x: 0; origin.y: 0; xScale: 1024 / global.mainWidth; yScale: 600 / global.mainHeight }
        // the EventManager must show some pages on top of everything else:
        // let's make it very "high"
        z: 1000
    }
}
