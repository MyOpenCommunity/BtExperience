import QtQuick 1.1
import Components.Text 1.0

Column {
    id: title

    property alias menuColumn: conn.target
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
            font.pixelSize: 12
            font.capitalization: Font.AllUppercase
        }
    }

    SvgImage {
        id: ribbon
        source: "../images/menu_column/ribbon_column-title.svg"
    }

    Connections {
        id: conn
        target: null
        onDestroyed: title.destroy()
    }

    Constants {
        id: constants
    }

    property bool enableAnimation: true
    Behavior on x {
        enabled: title.enableAnimation
        NumberAnimation { duration: constants.elementTransitionDuration }
    }

    Behavior on opacity {
        enabled: title.enableAnimation
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

