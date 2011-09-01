import QtQuick 1.0


MenuElement {
    id: element
    width: 192
    height: 250

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
            source: "common/dimmer_bg.png"

            Text {
                id: textTemperature
                x: 18
                y: 13
                text: qsTr("20° C")
                font.pixelSize: 22
            }

            Item {
                x: 0
                y: 50
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

                    Text {
                        id: currentProgram
                        x: 10
                        y: 30
                        width: 78
                        height: 15
                        text: qsTr("")
                        font.family: lightFont.name
                        wrapMode: Text.NoWrap
                        font.pixelSize: 13
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
                    id: image3
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
                        id: image5
                        x: 11
                        y: 12
                        source: "common/piu.png"
                    }
                }
            }

            ButtonOkCancel {
                id: buttonokcancel1
                x: 0
                y: 203
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
        }
    ]

}
