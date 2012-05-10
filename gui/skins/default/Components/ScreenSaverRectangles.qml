// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "ScreenSaverRectangles.js" as Script

Rectangle {
    id: screensaver
    width: 1024
    height: 600
    opacity: 0.7
    color: "black"
    clip: true

    Component {
        id: destryoingRect
        Rectangle {
            id: rect

            Timer {
                interval: 15000
                running: true
                repeat: false
                onTriggered: rect.destroy()
            }
        }
    }

    Timer {
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            var props = Script.generateProperties(parent.width, parent.height)
            destryoingRect.createObject(screensaver, props)
        }
    }
}
