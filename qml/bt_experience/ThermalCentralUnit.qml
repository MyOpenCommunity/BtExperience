import QtQuick 1.0

Item {
    id: mainItem
    width: 192
    height: 280
    signal loadComponent(string fileName)

    Item {
        anchors.top: parent.top
        id: programItem
        height: 50
        width: background.sourceSize.width

        Image {
            anchors.fill: parent
            z: 0
            id: background
            source: "common/tasto_menu.png";
        }

        Item {
            id: item2
            anchors.fill: parent
            z: 1

            Text {
                id: text
                text: "programma"
                font.family: semiBoldFont.name
                font.pixelSize: 13
                wrapMode: "WordWrap"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                anchors.right: arrow_right.left
            }

            Image {
                id: arrow_right
                source: "common/freccia_dx.png"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                mainItem.loadComponent("ThermalPrograms.qml")
                programItem.state = programItem.state == "" ? "selected" : ""
            }
        }

        states: State {
            name: "selected"
            PropertyChanges { target: text; color: "#ffffff" }
            PropertyChanges { target: arrow_right; source: "common/freccia_dxS.png" }
            PropertyChanges { target: background; source: "common/tasto_menuS.png" }
        }
    }




    Image {
        id: itemTemperature
        anchors.top: programItem.bottom
        anchors.topMargin: 0
        source: "common/comando_bg.png"

        Text {
            id: text1
            x: 17
            y: 12
            width: 158
            height: 15
            color: "#000000"
            text: qsTr("temperatura impostata")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
        }

        Text {
            id: text2
            x: 17
            y: 68
            width: 24
            height: 10
            color: "#ffffff"
            text: qsTr("22°")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
        }

        Image {
            id: image1
            x: 101
            y: 50
            source: "common/comando.png"

            Image {
                id: image4
                x: 11
                y: 12
                source: "common/meno.png"
            }
        }

        Image {
            id: image2
            x: 144
            y: 50
            source: "common/comando.png"

            Image {
                id: image3
                x: 11
                y: 12
                source: "common/piu.png"
            }
        }
    }

    Image {
        id: itemMode
        x: 0
        anchors.top: itemTemperature.bottom
        anchors.topMargin: 0
        source: "common/comando_bg.png"

        Image {
            id: image5
            x: 100
            y: 50
            source: "common/comando.png"

            Image {
                id: image6
                x: 43
                y: 0
                width: 44
                height: 45
                source: "common/comando.png"

                Image {
                    id: image8
                    x: 11
                    y: 12
                    source: "common/freccia_dw.png"
                }
            }

            Image {
                id: image7
                x: 11
                y: 12
                source: "common/freccia_up.png"
            }
        }

        Text {
            id: text3
            x: 19
            y: 14
            width: 154
            height: 15
            text: qsTr("modo")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
        }

        Text {
            id: text4
            x: 19
            y: 65
            color: "#ffffff"
            text: qsTr("estate")
            font.pixelSize: 14
        }
    }





}
