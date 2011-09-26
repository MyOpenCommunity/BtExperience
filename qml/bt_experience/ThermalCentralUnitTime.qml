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
        source: "common/ora.png"

        Text {
            id: text1
            x: 48
            y: 5
            text: qsTr("ore")
            font.pixelSize: 14
        }

        Text {
            id: text2
            x: 157
            y: 5
            text: qsTr("minuti")
            font.pixelSize: 14
        }

        Text {
            id: text3
            x: 50
            y: 41
            text: qsTr("15")
            font.pixelSize: 14
        }

        Text {
            id: text4
            x: 169
            y: 41
            text: qsTr("26")
            font.pixelSize: 14
        }

        Text {
            id: text5
            x: 50
            y: 68
            text: qsTr("16")
            font.pixelSize: 14
        }

        Text {
            id: text6
            x: 169
            y: 68
            text: qsTr("27")
            font.pixelSize: 14
        }

        Text {
            id: text7
            x: 50
            y: 105
            color: "#ffffff"
            text: qsTr("17")
            font.pixelSize: 14
        }

        Text {
            id: text8
            x: 169
            y: 105
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 14
        }

        Text {
            id: text9
            x: 50
            y: 138
            text: qsTr("18")
            font.pixelSize: 14
        }

        Text {
            id: text10
            x: 50
            y: 168
            text: qsTr("19")
            font.pixelSize: 14
        }

        Text {
            id: text11
            x: 169
            y: 138
            text: qsTr("29")
            font.pixelSize: 14
        }

        Text {
            id: text12
            x: 169
            y: 168
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
