import QtQuick 1.1

MenuElement {
    id: element
    width: 192
    height: 200

    function alertOkClicked() {
        element.closeElement()
    }

    Image {
        id: image1
        x: 0
        y: 0
        source: "common/data.png"

        Text {
            id: text1
            x: 82
            y: 5
            color: "#444546"
            text: qsTr("data")
            font.pixelSize: 12
        }

        Text {
            id: text2
            x: 34
            y: 24
            width: 29
            height: 15
            text: qsTr("mesi")
            font.pixelSize: 12
        }

        Text {
            id: text3
            x: 124
            y: 24
            text: qsTr("giorni")
            font.pixelSize: 12
        }

        Text {
            id: text4
            x: 16
            y: 53
            color: "#444546"
            text: qsTr("settembre")
            font.pixelSize: 12
        }

        Text {
            id: text6
            x: 18
            y: 89
            color: "#ffffff"
            text: qsTr("novembre")
            font.pixelSize: 12
        }

        Text {
            id: text7
            x: 20
            y: 111
            color: "#444546"
            text: qsTr("dicembre")
            font.pixelSize: 12
        }

        Text {
            id: text9
            x: 134
            y: 53
            color: "#444546"
            text: qsTr("26")
            font.pixelSize: 12
        }

        Text {
            id: text10
            x: 134
            y: 70
            color: "#444546"
            text: qsTr("27")
            font.pixelSize: 12
        }

        Text {
            id: text5
            x: 25
            y: 70
            color: "#444546"
            text: qsTr("ottobre")
            font.pixelSize: 12
        }

        Text {
            id: text8
            x: 24
            y: 128
            color: "#444546"
            text: qsTr("gennaio")
            font.pixelSize: 12
        }

        Text {
            id: text11
            x: 134
            y: 89
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 12
        }

        Text {
            id: text12
            x: 134
            y: 111
            color: "#444546"
            text: qsTr("29")
            font.pixelSize: 12
        }

        Text {
            id: text13
            x: 134
            y: 128
            color: "#444546"
            text: qsTr("30")
            font.pixelSize: 12
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 0
        y: 150
        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
        }
    }
}
