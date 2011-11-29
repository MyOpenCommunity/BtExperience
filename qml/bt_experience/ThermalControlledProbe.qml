import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 269

    function alertOkClicked() {
        element.closeElement()
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    function programSelected(programName) {
        programItem.description = programName
        if (programName == "off" || programName == "antigelo")
            element.state = "temperatureDisabled"
        else
            element.state = ""
    }

    Connections {
        target: dataModel
        onProbeStatusChanged: {
            var desc = "";
            switch (dataModel.probeStatus) {
            case ThermalControlledProbe.Auto:
                desc = "auto"
                break
            case ThermalControlledProbe.Antifreeze:
                desc = "antigelo"
                break
            case ThermalControlledProbe.Manual:
                desc = "manuale"
                break
            case ThermalControlledProbe.Off:
                desc = "off"
                break
            }
            programSelected(desc)
        }
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
                text: dataModel.temperature  / 10 + qsTr("° C")
                font.pixelSize: 24
            }

            MenuItem {
                id: programItem
                name: qsTr("programma")
                x: 0
                y: 51

                onClicked: {
                    element.loadElement("ThermalControlledProbePrograms.qml", programItem.name, dataModel)
                    if (programItem.state == "")
                        programItem.state =  "selected"
                }
            }

            Image {
                id: itemTemperature
                anchors.top: programItem.bottom
                anchors.topMargin: 0
                source: "common/comando_bg.png"
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
                    text:  dataModel.setpoint + "°"
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
                        onClicked: dataModel.setpoint -= 1
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
                        onClicked: dataModel.setpoint += 1
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
