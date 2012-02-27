import QtQuick 1.1

MenuElement {
    width: 212
    height: balance.height + equalizer.height + loudness.height

    ControlBalance {
        id: balance
        percentage: 10
    }

    MenuItem {
        id: equalizer
        name: qsTr("equalizzatore")
        anchors.top: balance.bottom
        description: "off"
        hasChild: true
    }

    MenuItem {
        id: loudness
        name: qsTr("loudness")
        anchors.top: equalizer.bottom
        description: "on"
        hasChild: true
    }
}
