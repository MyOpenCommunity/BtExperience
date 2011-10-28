import QtQuick 1.1

Image {
    id: command
    property bool selected: false
    signal clicked(bool newStatus)

    source: "common/btn_comando.png"

    Image {
        id: image1
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
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
                source: "common/btn_comandoS.png"
            }

            PropertyChanges {
                target: image1
                source: "common/freccia_dxS.png"
            }
        }
    ]
}

