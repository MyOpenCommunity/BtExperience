import QtQuick 1.1

Column {
    id: keypad

    property string mainLabel
    property string helperLabel: qsTr("enter code")
    property string errorLabel
    property string okLabel
    property string textInserted

    signal cancelClicked
    signal digitClicked(string digit)

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

    Text {
        text: mainLabel
        font.capitalization: Font.AllUppercase
        font.family: semiBoldFont.name
        font.pixelSize: 16
        color: "white"
    }

    Item {
        height: 5
        width: parent.width
    }

    Image {
        id: image1
        height: childrenRect.height // we force the height because the image is smaller than the children size
        source: "../images/common/bg_tastiera_codice.png"

        Rectangle {
            id: darkRect
            anchors.fill: parent
            z: 1
            opacity: 0
            color: "black"
            MouseArea { anchors.fill: parent }
        }

        Item {
            id: labelKeypad
            property string text: helperLabel
            width: parent.width
            height: 50
            z: 2
            anchors.top: parent.top

            Loader {
                id: labelLoader
                anchors.fill: parent
                sourceComponent: normalLabelText
            }

            Component {
                id: normalLabelText
                Text {
                    text: labelKeypad.text
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Component {
                id: errorLabelText
                Image {
                    source: "../images/common/bg_codice_errato.png"
                    Text {
                        anchors.fill: parent
                        text: errorLabel
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Component {
                id: okLabelText
                Image {
                    source: "../images/common/bg_codice_ok.png"
                    Text {
                        anchors.fill: parent
                        text: okLabel
                        font.pixelSize: 15
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }


        Grid {
            id: gridKeypad
            anchors.top: labelKeypad.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            rows: 3
            columns: 3
            Repeater {
                model: 9
                Image {
                    source: "../images/common/btn_tastiera_numero.png"
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: index + 1
                        MouseArea { anchors.fill: parent; onClicked: keypad.digitClicked(parent.text) }
                    }
                }
            }
        }

        Row {
            id: rowKeypad
            anchors.top: gridKeypad.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                source: "../images/common/btn_tastiera_numero.png"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "0"
                    MouseArea { anchors.fill: parent; onClicked: keypad.digitClicked(parent.text) }
                }
            }
            Image {
                source: "../images/common/btn_tastiera_canc.png"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("C")
                    MouseArea { anchors.fill: parent; onClicked: keypad.digitClicked(parent.text) }
                }
            }
        }

        Item {
            id: spaceKeypad
            anchors.top: rowKeypad.bottom
            height: 5
            width: parent.width
        }

        Image {
            id: cancelKeypad
            anchors.top: spaceKeypad.bottom
            source: "../images/common/btn_annulla.png"
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("cancel")
                font.pixelSize: 15
                font.capitalization: Font.AllUppercase

            }
            MouseArea { anchors.fill: parent; onClicked: keypad.cancelClicked() }
        }
    }

    states: [
        State {
            name: "error"
            PropertyChanges { target: labelLoader; sourceComponent: errorLabelText }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        },
        State {
            name: "ok"
            PropertyChanges { target: labelLoader; sourceComponent: okLabelText }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        },
        State {
            name: "disabled"
            PropertyChanges { target: darkRect; opacity: 0.7 }
        }
    ]
}

