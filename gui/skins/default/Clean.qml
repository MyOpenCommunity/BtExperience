import QtQuick 1.1
import Components.Text 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief The Clean page.

  This page implements the cleaning procedure.
  A countdown is shown at the center of the screen. During the countdown
  the user may clean the screen without causing any interaction with the
  application.
  Once the countdown reaches 0, the application resumes from the last
  execution point.
  */
BasePage {
    id: page

    property int remaining

    Rectangle {
        id: bg
        color: "black"
        anchors.fill: parent

        UbuntuMediumText {
            text: page.remaining
            font.pixelSize: 48
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
