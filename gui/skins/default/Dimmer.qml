import QtQuick 1.1

MenuElement {
    width: 212
    height: 370

    Image {
        source: "images/common/dimmer_bg.png"
        anchors.fill: parent
        ButtonOnOff {
            id: onOff
            status: dataModel.status
            onClicked: dataModel.status = newStatus
        }

        Text {
            id: textDimmer
            text: qsTr("light intensity")
            color: "#444546"
            wrapMode: "WordWrap"
            font.pixelSize: 13
            anchors.top: onOff.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: textPercentage
            text: dataModel.percentage + "%"
            font.bold: true
            color: "#444546"
            anchors.top: textDimmer.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: dimmerReg
            source: "images/common/dimmer_reg_bg.png"
            width: 212
            height: 50
            anchors.top: textPercentage.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: barPercentage
                source: "images/common/dimmer_reg.png"
                anchors.left: parent.left
                width: parent.width / 100 * dataModel.percentage
                height: 50
                Behavior on width {
                    NumberAnimation { duration: 100; }
                }
            }
        }

        ButtonMinusPlus {
            id: dimmerMinusPlus
            anchors.top: dimmerReg.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onPlusClicked: dataModel.increaseLevel()
            onMinusClicked: dataModel.decreaseLevel()
        }

        Image {
            width: 212
            height: 150
            source: "images/common/off_temporizzato.png"
            anchors.top: dimmerMinusPlus.bottom
            anchors.topMargin: 7

            Text {
                id: timeText
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("timed turn off")
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
                    text: qsTr("minutes")
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
                    text: qsTr("seconds")
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
