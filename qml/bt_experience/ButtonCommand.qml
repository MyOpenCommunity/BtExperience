import QtQuick 1.0

Image {
    id: command
    property bool selected: false
    signal clicked(bool newStatus)

    source: "common/comando.png"

    Image {
        id: image1
        x: 21
        y: 0
        source: "common/freccia_dx.png"
    }

    MouseArea {
        id: mouse_area1
        anchors.fill: parent
        onClicked: command.clicked(!selected)
    }
    states: [
        State {
            name: "State1"
            when: command.selected === true

            PropertyChanges {
                target: command
                source: "common/comandoS.jpg"
            }

            PropertyChanges {
                target: image1
                source: "common/freccia_dxS.png"
            }
        }
    ]
}

