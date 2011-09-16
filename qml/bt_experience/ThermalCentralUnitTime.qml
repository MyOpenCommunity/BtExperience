import QtQuick 1.0

MenuElement {
    id: element
    width: 192
    height: 150

    Image {
        id: image1
        x: 0
        y: 0
        source: "common/ora.png"

        Text {
            id: text1
            x: 36
            y: 5
            text: qsTr("ore")
            font.pixelSize: 12
        }

        Text {
            id: text2
            x: 123
            y: 5
            text: qsTr("minuti")
            font.pixelSize: 12
        }

        Text {
            id: text3
            x: 39
            y: 31
            text: qsTr("15")
            font.pixelSize: 12
        }

        Text {
            id: text4
            x: 134
            y: 31
            text: qsTr("26")
            font.pixelSize: 12
        }

        Text {
            id: text5
            x: 39
            y: 54
            text: qsTr("16")
            font.pixelSize: 12
        }

        Text {
            id: text6
            x: 134
            y: 54
            text: qsTr("27")
            font.pixelSize: 12
        }

        Text {
            id: text7
            x: 39
            y: 78
            color: "#ffffff"
            text: qsTr("17")
            font.pixelSize: 12
        }

        Text {
            id: text8
            x: 134
            y: 78
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 12
        }

        Text {
            id: text9
            x: 39
            y: 105
            text: qsTr("18")
            font.pixelSize: 12
        }

        Text {
            id: text10
            x: 39
            y: 125
            text: qsTr("19")
            font.pixelSize: 12
        }

        Text {
            id: text11
            x: 134
            y: 105
            text: qsTr("29")
            font.pixelSize: 12
        }

        Text {
            id: text12
            x: 134
            y: 125
            text: qsTr("30")
            font.pixelSize: 12
        }
    }
}
