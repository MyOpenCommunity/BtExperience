import QtQuick 1.1
import Components.Text 1.0
import "js/Stack.js" as Stack

BasePage {
    id: page

    property int remaining

    Rectangle {
        id: bg
        color: "black"
        anchors.fill: parent

        UbuntuMediumText {
            text: page.remaining
            color: "white"
            anchors.centerIn: bg
            anchors.verticalCenterOffset: -bg.height / 4
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            remaining -= 1
            if (remaining == 0)
                Stack.popPage()
        }
    }

    Component.onCompleted: remaining = global.guiSettings.cleanScreenTime
}
