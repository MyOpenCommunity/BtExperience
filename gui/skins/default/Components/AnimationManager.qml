import QtQuick 1.1
import Components 1.0
import "../js/Stack.js" as Stack

Item {
    id: item
    property string type: "slide"
    property alias animation: animationLoader.item

    Loader {
        id: animationLoader

        sourceComponent: {
            switch (item.type) {
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

}



