import QtQuick 1.1

Column {
    id: keypad
    property string mainLabel: qsTr("imposta zone")
    property string helperLabel: qsTr("inserisci il codice")
    property string errorLabel: qsTr("codice errato")
    property string okLabel: qsTr("zone impostate")
    property string textInserted


    signal cancelClicked
    signal digitClicked(string digit)

    Text {
        text: mainLabel
        font.capitalization: Font.AllUppercase
        font.family: semiBoldFont.name
        font.pixelSize: 16
        color: "white"
    }
    // A kind of spacing
    Item {
        height: 5
        width: parent.width
    }

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
        console.log('textInserted: ' + textInserted)
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

    Image {
        id: image1
        source: "../images/common/bg_tastiera_codice.png"

        Column {
            anchors.top: parent.top

            Item {
                id: labelKeypad
                property string text: helperLabel
                width: parent.width
                height: 50

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
                        text: "C"
                        MouseArea { anchors.fill: parent; onClicked: keypad.digitClicked(parent.text) }
                    }
                }
            }
            Item { height: 5; width: parent.width }

            Image {
                source: "../images/common/btn_annulla.png"
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("annulla")
                    font.pixelSize: 15
                    font.capitalization: Font.AllUppercase

                }
                MouseArea { anchors.fill: parent; onClicked: keypad.cancelClicked() }
            }
        }
    }
    states: [
        State {
            name: "errorState"
            PropertyChanges { target: labelLoader; sourceComponent: errorLabelText }
        },
        State {
            name: "okState"
            PropertyChanges { target: labelLoader; sourceComponent: okLabelText }
        }
    ]
}

