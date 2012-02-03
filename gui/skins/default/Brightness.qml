import QtQuick 1.1
import "Stack.js" as Stack
import BtObjects 1.0

Page {
    id: brightnessarea
    source: "images/home/home.jpg"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdHardwareSettings}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    Text {
        id: text1
        x: 383
        y: 83
        width: 208
        height: 0
        color: "#0a0a0d"
        text: qsTr("Regolazione luminosita")
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 18
    }

    Image {
        id: image1
        x: 160
        y: 136
        source: "images/1.png"
    }

    Image {
        id: image2
        x: 160
        y: 197
        source: "images/2.png"
    }

    Image {
        id: image3
        x: 160
        y: 257
        source: "images/3.png"
    }

    Image {
        id: image4
        x: 160
        y: 318
        source: "images/4.png"
    }

    Image {
        id: image5
        x: 160
        y: 375
        source: "images/5.png"
    }

    Rectangle {
        x: 160
        y: 136
        width: 40
        height: 40
        color: "red"

        MouseArea {
            id: mouse_area2
            anchors.fill: parent

            onClicked: {
                privateProps.model.brightness = 2
            }
        }
    }

    MouseArea {
        id: mouse_area4
        x: 160
        y: 197
        width: 40
        height: 40

        onClicked: {
            Settings.setBrightness("25")
            Settings.setBrightness("14")
            console.log ("i2cset -y 1 0x4a 0xf0 0x25")
            console.log ("i2cset -y 1 0x4a 0xf9 0x14")
        }
    }

    MouseArea {
        id: mouse_area5
        x: 160
        y: 257
        width: 40
        height: 40

        onClicked: {
            Settings.setBrightness("50")
            Settings.setBrightness("36")
            console.log ("i2cset -y 1 0x4a 0xf0 0x50")
            console.log ("i2cset -y 1 0x4a 0xf9 0x36")
        }
    }

    MouseArea {
        id: mouse_area6
        x: 160
        y: 318
        width: 40
        height: 40

        onClicked: {
            Settings.setBrightness("75")
            Settings.setBrightness("48")
            console.log ("i2cset -y 1 0x4a 0xf0 0x75")
            console.log ("i2cset -y 1 0x4a 0xf9 0x48")
        }
    }

    MouseArea {
        id: mouse_area8
        x: 160
        y: 375
        width: 40
        height: 40

        onClicked: {
            Settings.setBrightness("01")
            Settings.setBrightness("01")
            console.log ("i2cset -y 1 0x4a 0xf0 0x01")
            console.log ("i2cset -y 1 0x4a 0xf9 0x01")
        }
    }
}
