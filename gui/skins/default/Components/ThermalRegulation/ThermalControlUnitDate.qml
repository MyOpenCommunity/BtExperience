import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 220
    property string imagesPath: "../../images/"

    function alertOkClicked() {
        column.closeElement()
    }

    Image {
        id: image1
        x: 0
        y: 0
        width: 212
        height: 170
        source: imagesPath + "common/data.png"

        Text {
            id: text1
            x: 91
            y: 5
            color: "#444546"
            text: qsTr("data")
            font.pixelSize: 13
        }

        Text {
            id: text2
            x: 43
            y: 33
            width: 29
            height: 15
            text: qsTr("mesi")
            font.pixelSize: 13
        }

        Text {
            id: text3
            x: 139
            y: 33
            text: qsTr("giorni")
            font.pixelSize: 13
        }

        Text {
            id: text4
            x: 21
            y: 60
            color: "#444546"
            text: qsTr("settembre")
            font.pixelSize: 13
        }

        Text {
            id: text6
            x: 22
            y: 103
            color: "#ffffff"
            text: qsTr("novembre")
            font.pixelSize: 13
        }

        Text {
            id: text7
            x: 25
            y: 126
            color: "#444546"
            text: qsTr("dicembre")
            font.pixelSize: 13
        }

        Text {
            id: text9
            x: 149
            y: 60
            color: "#444546"
            text: qsTr("26")
            font.pixelSize: 13
        }

        Text {
            id: text10
            x: 149
            y: 82
            color: "#444546"
            text: qsTr("27")
            font.pixelSize: 13
        }

        Text {
            id: text5
            x: 32
            y: 82
            color: "#444546"
            text: qsTr("ottobre")
            font.pixelSize: 13
        }

        Text {
            id: text8
            x: 29
            y: 145
            color: "#444546"
            text: qsTr("gennaio")
            font.pixelSize: 13
        }

        Text {
            id: text11
            x: 149
            y: 103
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 13
        }

        Text {
            id: text12
            x: 149
            y: 126
            color: "#444546"
            text: qsTr("29")
            font.pixelSize: 13
        }

        Text {
            id: text13
            x: 149
            y: 145
            color: "#444546"
            text: qsTr("30")
            font.pixelSize: 13
        }
    }

    ButtonOkCancel {
        id: buttonokcancel1
        x: 0
        y: 170
        onCancelClicked: {
            pageObject.showAlert(column, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            column.closeElement()
        }
    }
}
