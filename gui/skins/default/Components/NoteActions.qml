import QtQuick 1.1
import BtObjects 1.0


Column {
    id: column

    signal editClicked
    signal deleteClicked

    opacity: 0

    Rectangle {
        width: 48
        height: 48
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#b7b7b7";
            }
            GradientStop {
                position: 1.00;
                color: "#ffffff";
            }
        }
        Image {
            source: "../images/icon_pencil.png"
            anchors.fill: parent
            anchors.margins: 10
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: column.editClicked()
        }
    }

    Rectangle {
        width: 48
        height: 48
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#b7b7b7";
            }
            GradientStop {
                position: 1.00;
                color: "#ffffff";
            }
        }
        Image {
            source: "../images/icon_trash.png"
            anchors.fill: parent
            anchors.margins: 10
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: column.deleteClicked()
        }
    }

    Behavior on opacity {
        NumberAnimation { target: column; property: "opacity"; duration: 200;}
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: column
                opacity: 1
            }
        }
    ]
}
