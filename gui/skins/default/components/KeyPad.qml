import QtQuick 1.1

Column {
    id: keypad
    property string mainText
    property string keypadText
    signal cancelClicked
    signal digitClicked(string digit)

    Text {
        text: mainText
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

    onDigitClicked: console.log('digit premuto: ' + digit)
    Image {
        id: image1
        source: "../images/common/bg_tastiera_codice.png"

        Column {
            anchors.top: parent.top

            Text {
                id: labelKeypad
                text: keypadText
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: 50
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
}

