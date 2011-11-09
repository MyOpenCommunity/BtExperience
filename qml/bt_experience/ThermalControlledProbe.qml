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
        buttonItem.state = "";
    }

    function programSelected(programName) {
        buttonItem.description = programName
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

                MenuItemDelegate {
                    id: buttonItem
                    showDescription: true
                    property string componentFile: "ThermalControlledProbePrograms.qml"
                    property string name: qsTr("programma")
                    property string description: ""
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        element.loadChild(buttonItem.name, buttonItem.componentFile)
                        if (buttonItem.state == "")
                            buttonItem.state =  "selected"
                    }
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
