import QtQuick 1.1

MenuElement {
    width: 212
    height: 370

    Image {
        width: 245
        height: 411
        anchors.bottomMargin: 39
        source: "common/dimmer_bg.png"
        anchors.fill: parent
        ButtonOnOff {
            id: onOff
            status: dataModel.status
            onClicked: dataModel.status = newStatus
        }

        Text {
            id: textDimmer
            text: qsTr("regolazione intensità luce dimmer")
            color: "#444546"
            wrapMode: "WordWrap"
            font.pixelSize: 13
            anchors.top: onOff.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
        }

        Image {
            id: dimmerReg
            source: "common/dimmer_reg_bg.png"
            width: 212
            height: 50
            anchors.top: textDimmer.bottom
            anchors.topMargin: 11
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: barPercentage
                source: "common/dimmer_reg.png"
                anchors.left: parent.left
                width: parent.width / 100 * dataModel.percentage
                height: 50

                Text {
                    text: dataModel.percentage + "%"
                    color: "#444546"
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        ButtonMinusPlus {
            id: dimmerMinusPlus
            anchors.top: dimmerReg.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onPlusClicked: {
                dataModel.percentage += 5
                if (dataModel.percentage > 100)
                    dataModel.percentage = 100
            }
            onMinusClicked: {
                dataModel.percentage -= 5
                if (dataModel.percentage < 0)
                    dataModel.percentage = 0
            }
        }

        Image {
            x: 0
            y: 240
            width: 212
            height: 150
            source: "common/off_temporizzato.png"
            anchors.top: dimmerMinusPlus.bottom
            anchors.topMargin: 15

            Text {
                id: timeText
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("spegnimento temporizzato")
                font.pointSize: 11
                color: "#444546"
            }

            Column {
                id: firstColumn
                anchors.top: timeText.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                width: parent.width / 2
                height: 131
                spacing: 3

                Text {
                    width: parent.width
                    text: qsTr("minuti")
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "0"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "1"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    color: "white"
                    width: parent.width
                    text: "2"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "3"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "4"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }

            }

            Column {
                id: secondColumn
                width: parent.width / 2
                anchors.topMargin: 8
                anchors.top: timeText.bottom
                anchors.left: firstColumn.right
                spacing: 3
                Text {
                    width: parent.width
                    text: qsTr("secondi")
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "26"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "27"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    color: "white"
                    width: parent.width
                    text: "28"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "29"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    width: parent.width
                    text: "30"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }
    }
}
