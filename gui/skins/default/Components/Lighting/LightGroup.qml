import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 39

    Item {
        id: control

        property int marginLeftRight: 7
        property int marginTopBottom: 5

        width: 212
        height: 37
        Image {
            id: imgOn

            source: areaOn.pressed ? "../../images/common/button_1-2_p.svg" :
                                     "../../images/common/button_1-2.svg"
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
                onClicked: column.dataModel.setActive(true)
            }
        }

        Image {
            anchors {
                left: imgOn.left
                top: imgOn.bottom
                right: imgOn.right
            }
            source: "../../images/common/shadow_button_1-2.svg"
            visible: (areaOn.pressed === false)
        }

        Image {
            id: imgOff

            source: areaOff.pressed ? "../../images/common/button_1-2_p.svg" :
                                      "../../images/common/button_1-2.svg"
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
                color: "black"
                font.pixelSize: 11
                anchors.centerIn: parent
            }

            MouseArea {
                id: areaOff
                anchors.fill: parent
                onClicked: column.dataModel.setActive(false)
            }
        }

        Image {
            anchors {
                left: imgOff.left
                top: imgOff.bottom
                right: imgOff.right
            }
            source: "../../images/common/shadow_button_1-2.svg"
            visible: (areaOff.pressed === false)
        }
    }
}
