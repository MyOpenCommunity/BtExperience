import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 220
    property string imagesPath: "../../images/"

    function alertOkClicked() {
        column.closeColumn()
    }

    Image {
        id: image1
        x: 0
        y: 0
        width: 212
        height: 170
        source: imagesPath + "common/ora.png"

        Text {
            id: text1
            x: 45
            y: 5
            text: qsTr("ore")
            font.pixelSize: 13
        }

        Text {
            id: text2
            x: 139
            y: 5
            text: qsTr("minuti")
            font.pixelSize: 13
        }

        Text {
            id: text3
            x: 48
            y: 35
            text: qsTr("15")
            font.pixelSize: 13
        }

        Text {
            id: text4
            x: 151
            y: 35
            text: qsTr("26")
            font.pixelSize: 13
        }

        Text {
            id: text5
            x: 48
            y: 60
            text: qsTr("16")
            font.pixelSize: 13
        }

        Text {
            id: text6
            x: 151
            y: 60
            text: qsTr("27")
            font.pixelSize: 13
        }

        Text {
            id: text7
            x: 48
            y: 89
            color: "#ffffff"
            text: qsTr("17")
            font.pixelSize: 13
        }

        Text {
            id: text8
            x: 151
            y: 89
            color: "#ffffff"
            text: qsTr("28")
            font.pixelSize: 13
        }

        Text {
            id: text9
            x: 48
            y: 120
            text: qsTr("18")
            font.pixelSize: 13
        }

        Text {
            id: text10
            x: 48
            y: 144
            text: qsTr("19")
            font.pixelSize: 13
        }

        Text {
            id: text11
            x: 151
            y: 120
            text: qsTr("29")
            font.pixelSize: 13
        }

        Text {
            id: text12
            x: 151
            y: 144
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
            column.closeColumn()
        }
    }
}
