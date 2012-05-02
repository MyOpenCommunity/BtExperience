import QtQuick 1.1
import "../js/datetime.js" as DateTime

Image {
    id: control
    width: 212
    height: 170
    source: "../images/common/dimmer_bg.png"
    property string text
    property string date: DateTime.format(new Date())["date"]
    property string time: DateTime.format(new Date())["time"]


    QtObject {
        id: privateProps
        property int current_element: -1
    }

    Text {
        id: text1
        x: 22
        y: 68
        width: 115
        height: 24
        color: "#ffffff"
        text: control.date
        font.bold: true
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignTop
        font.pixelSize: 16
    }

    Text {
        id: text2
        x: 22
        y: 113
        width: 79
        height: 19
        color: "#ffffff"
        text: control.time
        font.bold: true
        verticalAlignment: Text.AlignTop
        font.pixelSize: 16
    }

    Text {
        id: text3
        x: 22
        y: 11
        width: 149
        height: 15
        text: control.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
    }

    ButtonCommand {
        x: 159
        y: 68
        width: 43
        height: 45
        selected: privateProps.current_element == 1

        onClicked: {
            if (!selected) {
                privateProps.current_element = 1
            }
        }
    }

    ButtonCommand {
        x: 159
        y: 113
        width: 43
        height: 45
        selected: privateProps.current_element == 2
        onClicked: {
            if (!selected) {
                privateProps.current_element = 2
            }
        }
    }
}
