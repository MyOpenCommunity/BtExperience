import QtQuick 1.1
import Components.Text 1.0


/**
  \ingroup Core

  \brief A component appearing above a MenuItem showing its title.
  */
SvgImage {
    id: title

    /** the MenuColumn component this MenuTitle refers to */
    property Item menuColumn: null
    /** type:string the text to be shown */
    property alias text: label.text

    source: "../images/menu_column/label_column-title.svg"
    opacity: menuColumn.opacity
    width: menuColumn.width

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
        elide: Text.ElideRight
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

