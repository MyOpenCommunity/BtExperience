import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    property alias text: label.text

    property int status: 0 // 0 - gray, 1 - green

    source: "../../images/common/led_grey.svg"

    UbuntuLightText {
        id: label
        color: "black"
        anchors.centerIn: parent
        font.pixelSize: 6
    }

    states: [
        State {
            name: "green"
            when: status === 1
            PropertyChanges { target: bg; source: "../../images/common/led_green.svg" }
        }
    ]
}
