import QtQuick 1.1
import Components.Text 1.0

SvgImage {
    id: control

    property alias status: switchId.status
    property string upperText: ""
    property string text
    property int pixelSize: 15
    property bool enabled: true

    signal pressed

    source: "../images/common/panel_212x50.svg";

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: control.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    Component {
        id: textComponent

        UbuntuLightText {
            text: control.text
            font.pixelSize: control.pixelSize
            color: "white"
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
            }
        }
    }

    Component {
        id: labelsComponent

        Item {
            anchors.fill: parent

            UbuntuLightText {
                text: control.text
                font.pixelSize: control.pixelSize
                color: "white"
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 4
                    left: parent.left
                    right: parent.right
                }
            }

            UbuntuLightText {
                text: control.upperText
                font.pixelSize: control.pixelSize
                color: "white"
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                anchors {
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 4
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }

    Loader {
        id: labelsLoader

        sourceComponent: upperText === "" ? textComponent : labelsComponent
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: parent.width / 100 * 4
            right: switchId.left
            rightMargin: parent.width / 100 * 2
        }
    }

    Switch {
        id: switchId
        bgImage: "../images/common/bg_cursore.svg"
        leftImageBg: "../images/common/btn_temporizzatore_abilitato.svg"
        leftImage: "../images/common/ico_temporizzatore_abilitato.svg"
        arrowImage: "../images/common/ico_sposta_dx.svg"
        rightImageBg: "../images/common/btn_temporizzatore_disabilitato.svg"
        rightImage: "../images/common/ico_temporizzatore_disabilitato.svg"
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: parent.width / 100 * 4
        }

        status: 0
        onPressed: control.pressed()
    }
}
