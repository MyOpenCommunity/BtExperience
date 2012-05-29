import QtQuick 1.1


Item {
    id: control

    property int marginLeftRight: 7
    property int marginTopBottom: 5
    property int status: 1
    property alias onText: textOn.text
    property alias offText: textOff.text

    signal clicked(bool newStatus)

    width: 212
    height: 37

    SvgImage {
        id: imgOn

        source: areaOn.pressed && status === 1 ? "../images/common/button_1-2_p.svg" :
                                                 "../images/common/button_1-2.svg"
        width: (parent.width - 2 * control.marginLeftRight) / 2
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            topMargin: control.marginTopBottom
            bottomMargin: control.marginTopBottom
            leftMargin: control.marginLeftRight
        }

        Text {
            id: textOn

            text: qsTr("ON")
            color: "black"
            font.pixelSize: 11
            anchors.centerIn: parent
        }

        MouseArea {
            id: areaOn
            anchors.fill: parent
            onClicked: control.clicked(true)
        }
    }

    SvgImage {
        anchors {
            left: imgOn.left
            top: imgOn.bottom
            right: imgOn.right
        }
        source: "../images/common/shadow_button_1-2.svg"
        visible: (areaOn.pressed === false) && (control.status === 0)
    }

    SvgImage {
        id: imgOff

        source: areaOff.pressed && status === 0 ? "../images/common/button_1-2_p.svg" :
                                                  "../images/common/button_1-2_s.svg"
        width: (parent.width - 2 * control.marginLeftRight) / 2
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            topMargin: control.marginTopBottom
            bottomMargin: control.marginTopBottom
            rightMargin: control.marginLeftRight
        }

        Text {
            id: textOff

            text: qsTr("OFF")
            color: "white"
            font.pixelSize: 11
            anchors.centerIn: parent
        }

        MouseArea {
            id: areaOff
            anchors.fill: parent
            onClicked: control.clicked(false)
        }
    }

    SvgImage {
        anchors {
            left: imgOff.left
            top: imgOff.bottom
            right: imgOff.right
        }
        source: "../images/common/shadow_button_1-2.svg"
        visible: (areaOff.pressed === false) && (control.status === 1)
    }

    states: [
        State {
            when: status === 1
            name: "on"
            PropertyChanges { target: imgOn; source: "../images/common/button_1-2_s.svg" }
            PropertyChanges { target: textOn; color: "white" }
            PropertyChanges { target: imgOff; source: "../images/common/button_1-2.svg" }
            PropertyChanges { target: textOff; color: "black" }
        },
        State {
            when: status === -1
            name: "disabled"
            PropertyChanges { target: imgOn; source: "../images/common/button_1-2.svg" }
            PropertyChanges { target: textOn; color: "black" }
            PropertyChanges { target: imgOff; source: "../images/common/button_1-2.svg" }
            PropertyChanges { target: textOff; color: "black" }
        }
    ]
}
