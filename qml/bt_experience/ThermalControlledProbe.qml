import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + buttonokcancel.height + itemLoader.height

    function alertOkClicked() {
        element.closeElement()
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    function programSelected(programName) {
        programItem.description = programName
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

    Image {
        id: fixedItem
        anchors.top: parent.top
        width: parent.width
        height: 100
        source: "images/common/dimmer_bg.png"

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
    }

    Component {
        id: temperatureComponent
        Image {

            id: itemTemperature
            visible: true

            source: "images/common/comando_bg.png"
            width: element.width
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
                source: "images/common/btn_comando.png"

                Image {
                    id: image4
                    x: 14
                    y: 15
                    source: "images/common/meno.png"
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
                source: "images/common/btn_comando.png"

                Image {
                    id: image5
                    x: 14
                    y: 15
                    source: "images/common/piu.png"
                }

                MouseArea {
                    id: plusMouseArea
                    anchors.fill: parent
                    onClicked: dataModel.setpoint += 1
                }
            }
        }
    }

    Loader {
        id: itemLoader
        anchors.top: fixedItem.bottom
        sourceComponent: temperatureComponent
    }

    ButtonOkCancel {
        id: buttonokcancel
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onCancelClicked: {
            page.showAlert(element, "Modifiche non salvate. Continuare?")
        }

        onOkClicked: {
            element.closeElement()
        }
    }


}
