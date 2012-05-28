import QtQuick 1.1
import Components 1.0

Image {
    id: control
    source: "../../images/common/date_panel_background.svg"
    width: 265
    height: 188
    property alias title: title.text

    Text {
        id: title
        color: "#000000"
        text: qsTr("timing")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }


    QtObject {
        id: privateProps
        property bool enabled: true
    }

    Row {
        id: disableRow
        anchors {
            top: title.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        SvgImage {
            id: enabledImage
            source: enabledArea.pressed ? "../../images/common/button_background_press.svg" :
                                          "../../images/common/button_background.svg"

            Text {
                text: qsTr("enabled")
                anchors.centerIn: parent
                font.capitalization: Font.SmallCaps
            }

            MouseArea {
                id: enabledArea
                anchors.fill: parent
                onClicked: privateProps.enabled = true
            }

            states: State {
                name: "selected"
                when: privateProps.enabled === true
                PropertyChanges {
                    target: enabledImage
                    source: "../../images/common/button_background_select.svg"
                }
            }
        }

        SvgImage {
            id: disabledImage
            source: disabledArea.pressed ? "../../images/common/button_background_press.svg" :
                                           "../../images/common/button_background.svg"

            Text {
                text: qsTr("disabled")
                anchors.centerIn: parent
                font.capitalization: Font.SmallCaps
            }

            MouseArea {
                id: disabledArea
                anchors.fill: parent
                onClicked: privateProps.enabled = false
            }

            states: State {
                name: "selected"
                when: privateProps.enabled === false
                PropertyChanges {
                    target: disabledImage
                    source: "../../images/common/button_background_select.svg"
                }
            }
        }
    }

    ControlPlusMinusDateTime {
        id: timingButtons
        anchors.top: disableRow.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        leftLabel: "hours"
        centerLabel: "minutes"
        rightLabel: "seconds"
    }


    Rectangle {
        id:darkRect
        z: 1
        anchors.fill: timingButtons

        color: "grey"
        opacity: 0

        MouseArea {
            anchors.fill: parent
        }
    }

    states: [
        State {
            name: "disabled"
            when: privateProps.enabled === false
            PropertyChanges {
                target: darkRect
                opacity: 0.6
            }
        }

    ]
}

