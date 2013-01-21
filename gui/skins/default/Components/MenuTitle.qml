import QtQuick 1.1
import Components.Text 1.0

Column {
    id: title

    property Item menuColumn: null
    property alias text: label.text

    SvgImage {
        id: background
        source: "../images/menu_column/label_column-title.svg"

        UbuntuLightText {
            id: label
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 5
                verticalCenter: parent.verticalCenter
            }

            color: "black"
            font.bold: true
            font.pixelSize: 14
            font.capitalization: Font.AllUppercase
        }
    }

    Connections {
        id: conn
        target: title.menuColumn
        onDestroyed: title.destroy()
    }

    Constants {
        id: constants
    }

    Behavior on x {
        enabled: menuColumn === null ? false : menuColumn.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }

    Behavior on opacity {
        enabled: menuColumn === null ? false : menuColumn.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }

    states: [
        State {
            name: "selected"
            when: menuColumn.isLastColumn
            PropertyChanges { target: background; source: "../images/menu_column/label_column-title_p.svg" }
            PropertyChanges { target: label; color: "white" }
        }
    ]
}

