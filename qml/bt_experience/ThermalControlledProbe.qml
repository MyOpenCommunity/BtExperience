import QtQuick 1.1


MenuElement {
    id: element
    width: 212
    height: 269

    function alertOkClicked() {
        element.closeElement()
    }

    onChildLoaded: {
        child.programSelected.connect(programSelected)
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    function programSelected(programName) {
        currentProgram.text = programName
        if (programName == "off" || programName == "antigelo")
            element.state = "temperatureDisabled"
        else
            element.state = ""
    }

    Item {
        anchors.fill: parent
        id: mainItem

        Image {
            id: image1
            x: 0
            y: 0
            width: 212
            height: 145
            source: "common/dimmer_bg.png"

            Text {
                id: textTemperature
                x: 18
                y: 13
                text: qsTr("20° C")
                font.pixelSize: 24
            }

            Item {
                x: 0
                y: 51
                id: programItem
                height: 50
                width: background.sourceSize.width

                Image {
                    anchors.fill: parent
                    z: 0
                    id: background
                    width: 212
                    height: 50
                    anchors.rightMargin: 0
                    source: "common/btn_menu.png";
                }

                Item {
                    id: item2
                    x: 0
                    y: 0
                    width: 212
                    height: 50
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.topMargin: 0
                    anchors.fill: parent
                    z: 1

                    Text {
                        id: text
                        x: 16
                        y: 5
                        width: 177
                        height: 55
                        text: "programma"
                        anchors.rightMargin: 30
                        font.family: semiBoldFont.name
                        font.pixelSize: 13
                        wrapMode: "WordWrap"
                        anchors.left: parent.left
                        anchors.leftMargin: 16
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

                    Text {
                        id: currentProgram
                        x: 16
                        y: 30
                        width: 92
                        height: 15
                        text: qsTr("")
                        font.family: lightFont.name
                        wrapMode: Text.NoWrap
                        font.pixelSize: 15
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        element.loadChild("", "ThermalControlledProbePrograms.qml")
                        programItem.state = programItem.state == "" ? "selected" : ""
                    }
                }

                states: State {
                    name: "selected"
                    PropertyChanges { target: text; color: "#ffffff" }
                    PropertyChanges { target: currentProgram; color: "#ffffff" }
                    PropertyChanges { target: arrow_right; source: "common/freccia_dxS.png" }
                    PropertyChanges { target: background; source: "common/btn_menuS.png" }
                }
            }

            Image {
                id: itemTemperature
                anchors.top: programItem.bottom
                anchors.topMargin: 0
                source: "common/comando_bg.png"
                property int temperature: 22
                x: 0
                y: 116
                width: 212
                height: 118

                Text {
                    id: text1
                    x: 17
                    y: 12
                    width: 158
                    height: 15
                    color: "#000000"
                    text: qsTr("temperatura impostata")
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 13
                }

                Text {
                    id: labelTemperature
                    x: 17
                    y: 78
                    width: 24
                    height: 15
                    color: "#ffffff"
                    text:  itemTemperature.temperature + "°"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 15
                }

                Image {
                    id: minusTemperature
                    x: 111
                    y: 59
                    width: 49
                    height: 53
                    source: "common/btn_comando.png"

                    Image {
                        id: image4
                        x: 14
                        y: 15
                        source: "common/meno.png"
                    }

                    MouseArea {
                        id: minusMouseArea
                        anchors.fill: parent
                        onClicked: itemTemperature.temperature -= 1
                    }
                }

                Image {
                    id: plusTemperature
                    x: 160
                    y: 59
                    width: 49
                    height: 53
                    source: "common/btn_comando.png"

                    Image {
                        id: image5
                        x: 14
                        y: 15
                        source: "common/piu.png"
                    }

                    MouseArea {
                        id: plusMouseArea
                        anchors.fill: parent
                        onClicked: itemTemperature.temperature += 1
                    }
                }
            }

            ButtonOkCancel {
                id: buttonokcancel1
                x: 0
                y: 219
                anchors.top: itemTemperature.bottom
                anchors.topMargin: 0

                onCancelClicked: {
                    page.showAlert(element, "Modifiche non salvate. Continuare?")
                }

                onOkClicked: {
                    element.closeElement()
                }
            }


        }
    }
    states: [
        State {
            name: "temperatureDisabled"

            PropertyChanges {
                target: itemTemperature
                opacity: 0.400
            }

            PropertyChanges {
                target: minusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: plusMouseArea
                enabled: false
            }
        }
    ]

}
