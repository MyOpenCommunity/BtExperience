import QtQuick 1.1
import "../js/datetime.js" as DateTime

Image {
    id: control
    width: 212
    height: 170
    source: "../images/common/dimmer_bg.png"
    property string text: "valid until"
    property string date: DateTime.format(new Date())["date"]
    property string time: DateTime.format(new Date())["time"]

    signal dateClicked
    signal timeClicked

    function resetSelection() {
        privateProps.currentElement = -1
    }


    QtObject {
        id: privateProps
        property int currentElement: -1
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
        selected: privateProps.currentElement == 1

        onClicked: {
            if (!selected) {
                privateProps.currentElement = 1
                control.dateClicked()
            }
        }
    }

    ButtonCommand {
        x: 159
        y: 113
        width: 43
        height: 45
        selected: privateProps.currentElement == 2
        onClicked: {
            if (!selected) {
                privateProps.currentElement = 2
                control.timeClicked()
            }
        }
    }
}
