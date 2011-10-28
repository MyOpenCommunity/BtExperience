import QtQuick 1.1

Text {
    width: 212
    height: 33
    color: "#ffffff"
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: 15
    font.family: semiBoldFont.name
    font.capitalization: Font.AllUppercase

    property alias enableAnimation: animation.enabled
    Behavior on x {
        id: animation
        NumberAnimation { duration: 400 }
    }

}

