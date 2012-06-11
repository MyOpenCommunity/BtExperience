import QtQuick 1.1

SvgImage {
    id: keypad

    property string mainLabel
    property string helperLabel: qsTr("enter code")
    property string errorLabel
    property string okLabel
    property string textInserted

    signal cancelClicked
    signal digitClicked(string digit)

    source: "../images/common/panel_keypad.svg"

    onCancelClicked: {
        textInserted = ""
    }

    onDigitClicked: {
        if (digit === "C") {
            if (textInserted.length > 0)
                textInserted = textInserted.substring(0, textInserted.length - 1)
        }
        else
            textInserted += digit
    }

    onTextInsertedChanged: {
        if (textInserted !== "") {
            var textString = "";
            for (var i = 0; i < textInserted.length; ++i)
                textString += "*"
            labelKeypad.text = textString
        }
        else
            labelKeypad.text = helperLabel
    }

    SvgImage {
        id: display

        source: "../images/common/keypad_display_background.svg"
        anchors.top: parent.top
        anchors.topMargin: keypad.height / 100 * 4.65
        anchors.horizontalCenter: parent.horizontalCenter

        UbuntuLightText {
            id: titleLabel
            text: mainLabel
            font.capitalization: Font.AllUppercase
            font.pixelSize: 16
            color: "black"
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            id: labelKeypad
            property string text: helperLabel
            anchors.top: titleLabel.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            z: 2

            Loader {
                id: labelLoader
                anchors.fill: parent
                sourceComponent: normalLabelText
            }

            Component {
                id: normalLabelText

                UbuntuLightText {
                    text: labelKeypad.text
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Component {
                id: errorLabelText

                Item {
                    SvgImage {
                        id: iconFail
                        source: "../images/common/icon_input_fail.svg"
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: keypad.width / 100 * 11.95
                    }
                    UbuntuLightText {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: iconFail.right
                        anchors.leftMargin: keypad.width / 100 * 11.95
                        text: errorLabel
                        font.pixelSize: 15
                        font.bold: true
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Component {
                id: okLabelText

                Item {
                    SvgImage {
                        id: iconCorrect
                        source: "../images/common/icon_input_correct.svg"
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: keypad.width / 100 * 11.95
                    }
                    UbuntuLightText {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: iconCorrect.right
                        anchors.leftMargin: keypad.width / 100 * 11.95
                        text: okLabel
                        font.pixelSize: 15
                        font.bold: true
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    Item {
        id: keypadBase

        anchors {
            top: display.bottom
            topMargin: keypad.height / 100 * 6.2
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Rectangle {
            id: darkRect
            anchors.fill: parent
            z: 1
            opacity: 0
            color: "black"
            MouseArea { anchors.fill: parent }
        }

        Item {
            id: spaceKeypad
            anchors.top: parent.top
            height: keypad.height / 100 * 6.2
            width: parent.width
        }

        Column {
            id: gridKeypad
            anchors.top: spaceKeypad.top
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 1
                        onClicked: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }

            Item {
                height: keypad.height / 100 * 6.2
                width: 1
            }

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 4
                        onClicked: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }

            Item {
                height: keypad.height / 100 * 6.2
                width: 1
            }

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 7
                        onClicked: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }
        }

        Item {
            id: spaceKeypad2
            anchors.top: gridKeypad.bottom
            height: keypad.height / 100 * 6.2
            width: parent.width
        }

        Row {
            id: rowKeypad
            anchors.top: spaceKeypad2.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            ButtonThreeStates {
                defaultImage: "../images/common/button_key_delete.svg"
                pressedImage: "../images/common/button_key_delete_press.svg"
                shadowImage: "../images/common/shadow_button_key_delete.svg"
                text: ""
                onClicked: keypad.digitClicked("C")
                status: 0

                SvgImage {
                    source: parent.state === "pressed" ? "../images/common/key_delete_press.svg" : "../images/common/key_delete.svg"
                    anchors.centerIn: parent
                }
            }

            ButtonThreeStates {
                defaultImage: "../images/common/button_keypad.svg"
                pressedImage: "../images/common/button_keypad_press.svg"
                shadowImage: "../images/common/shadow_button_keypad.svg"
                text: "0"
                onClicked: keypad.digitClicked(text)
                status: 0
            }
        }
    }

    states: [
        State {
            name: "error"
            PropertyChanges { target: labelLoader; sourceComponent: errorLabelText }
            PropertyChanges { target: titleLabel; visible: false }
            PropertyChanges { target: labelKeypad; anchors.fill: parent }
            PropertyChanges { target: labelKeypad; anchors.margins: keypad.height / 100 * 4.65 }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        },
        State {
            name: "ok"
            PropertyChanges { target: labelLoader; sourceComponent: okLabelText }
            PropertyChanges { target: titleLabel; visible: false }
            PropertyChanges { target: labelKeypad; anchors.fill: parent }
            PropertyChanges { target: labelKeypad; anchors.margins: keypad.height / 100 * 4.65 }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        },
        State {
            name: "disabled"
            PropertyChanges { target: darkRect; opacity: 0.7 }
        }
    ]
}

