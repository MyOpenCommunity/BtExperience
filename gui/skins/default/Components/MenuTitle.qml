import QtQuick 1.1
import Components.Text 1.0


UbuntuLightText {
    id: title

    property alias menuColumn: conn.target

    width: 212
    height: constants.navbarTopMargin // guarantees a proper alignment with the back button
    color: "#ffffff"
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: 15
    font.capitalization: Font.AllUppercase

    Connections {
        id: conn
        target: null
        onDestroyed: title.destroy()
    }

    Constants {
        id: constants
    }

    property bool enableAnimation: true
    Behavior on x {
        enabled: title.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }

    Behavior on opacity {
        enabled: title.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }
}

