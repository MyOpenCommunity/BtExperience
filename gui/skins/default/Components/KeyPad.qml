import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: keypad

    property string mainLabel
    property string helperLabel: "enter code"
    property string errorLabel
    property string okLabel
    property string textInserted

    signal cancelClicked
    signal closePopup
    signal digitClicked(string digit)

    source: "../images/common/panel_274x284.svg"

    onCancelClicked: {
        textInserted = ""
        keypad.closePopup()
    }

    onDigitClicked: {
        if (digit === "C") {
            if (textInserted.length > 0)
                textInserted = textInserted.substring(0, textInserted.length - 1)
            else
                keypad.cancelClicked()
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
        anchors.topMargin: Math.round(keypad.height / 100 * 5)
        anchors.horizontalCenter: parent.horizontalCenter

        UbuntuLightText {
            id: titleLabel
            text: mainLabel
            font.capitalization: Font.AllUppercase
            font.pixelSize: 18
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
                    font.pixelSize: 16
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
                        anchors.leftMargin: Math.round(keypad.width / 100 * 11.95)
                    }
                    UbuntuMediumText {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: iconFail.right
                        anchors.leftMargin: Math.round(keypad.width / 100 * 11.95)
                        text: errorLabel
                        font.pixelSize: 15
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
                        anchors.leftMargin: Math.round(keypad.width / 100 * 11.95)
                    }
                    UbuntuMediumText {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: iconCorrect.right
                        anchors.leftMargin: Math.round(keypad.width / 100 * 11.95)
                        text: okLabel
                        font.pixelSize: 15
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
            topMargin: Math.round(keypad.height / 100 * 5)
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

        Column {
            id: gridKeypad
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: keypad.height / 100 * 3

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 1
                        font.pixelSize: 18
                        onPressed: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 4
                        font.pixelSize: 18
                        onPressed: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }

            Row {
                Repeater {
                    model: 3
                    ButtonThreeStates {
                        defaultImage: "../images/common/button_keypad.svg"
                        pressedImage: "../images/common/button_keypad_press.svg"
                        shadowImage: "../images/common/shadow_button_keypad.svg"
                        text: index + 7
                        font.pixelSize: 18
                        onPressed: keypad.digitClicked(text)
                        status: 0
                    }
                }
            }

            Row {
                id: rowKeypad

                ButtonThreeStates {
                    defaultImage: "../images/common/button_key_delete.svg"
                    pressedImage: "../images/common/button_key_delete_press.svg"
                    shadowImage: "../images/common/shadow_button_key_delete.svg"
                    text: ""
                    onPressed: keypad.digitClicked("C")

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
                    font.pixelSize: 18
                    onPressed: keypad.digitClicked(text)
                }
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

