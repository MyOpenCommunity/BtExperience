import QtQuick 1.1

MenuElement {
    id: element
    width: 245
    height: 255

    function alertOkClicked() {
        element.closeElement()
    }

    Image {
        id: image1
        x: 0
        y: 0
        width: 245
        height: 198
        source: "common/data.png"

        Text {
            id: text1
            x: 108
            y: 6
            color: "#444546"
            text: qsTr("data")
            font.pixelSize: 14
        }

        Text {
            id: text2
            x: 43
            y: 31
            width: 29
            height: 15
            text: qsTr("mesi")
            font.pixelSize: 14
        }

        Text {
            id: text3
            x: 159
            y: 31
            text: qsTr("giorni")
            font.pixelSize: 14
        }

        Text {
            id: text4
            x: 25
            y: 70
            color: "#444546"
            text: qsTr("settembre")
            font.pixelSize: 14
        }

        Text {
            id: text6
            x: 25
            y: 121
            color: "#ffffff"
            text: qsTr("novembre")
            font.pixelSize: 14
        }

        Text {
            id: text7
            x: 26
            y: 148
            color: "#444546"
            text: qsTr("dicembre")
            font.pixelSize: 14
        }

        Text {
            id: text9
            x: 169
            y: 70
            color: "#444546"
            text: qsTr("26")
            font.pixelSize: 14
        }

        Text {
            id: text10
            x: 169
            y: 92
            color: "#444546"
            text: qsTr("27")
            font.pixelSize: 14
        }

        Text {
            id: text5
            x: 33
            y: 92
            color: "#444546"
            text: qsTr("ottobre")
            font.pixelSize: 14
        }

        Text {
            id: text8
            x: 29
            y: 172
            color: "#444546"
            text: qsTr("gennaio")
            font.pixelSize: 14
        }

        Text {
            id: text11
            x: 169
            y: 121
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 14
        }

        Text {
            id: text12
            x: 169
            y: 148
            color: "#444546"
            text: qsTr("29")
            font.pixelSize: 14
        }

        Text {
            id: text13
            x: 169
            y: 172
            color: "#444546"
            text: qsTr("30")
            font.pixelSize: 14
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 1
        y: 198
        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
        }
    }
}
