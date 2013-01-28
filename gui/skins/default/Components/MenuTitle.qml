import QtQuick 1.1
import Components.Text 1.0

SvgImage {
    id: title

    property Item menuColumn: null
    property alias text: label.text

    source: "../images/menu_column/label_column-title.svg"
    opacity: menuColumn.opacity

    Constants {
        id: constants
    }

    UbuntuMediumText {
        id: label

        color: "black"
        font.pixelSize: 14
        font.capitalization: Font.AllUppercase
        anchors {
            left: parent.left
            leftMargin: parent.width / 100 * 5
            right: parent.right
            rightMargin: parent.width / 100 * 5
            verticalCenter: parent.verticalCenter
        }
    }

    Connections {
        id: conn
        target: title.menuColumn
        onDestroyed: title.destroy()
    }

    states: [
        State {
            name: "selected"
            when: menuColumn.isLastColumn
            PropertyChanges { target: title; source: "../images/menu_column/label_column-title_p.svg" }
            PropertyChanges { target: label; color: "white" }
        }
    ]
}

