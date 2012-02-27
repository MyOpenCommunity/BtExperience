import QtQuick 1.1
import "constants.js" as Constants

Text {
    id: title
    width: 212
    height: 33
    color: "#ffffff"
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: 15
    font.family: semiBoldFont.name
    font.capitalization: Font.AllUppercase

    property bool enableAnimation: true
    Behavior on x {
        enabled: title.enableAnimation
        NumberAnimation { duration: Constants.elementTransitionDuration }
    }

    Behavior on opacity {
        enabled: title.enableAnimation
        NumberAnimation { duration: Constants.elementTransitionDuration }
    }
}

