import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    width: 212
    height: 323

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
        programItem.description = programName
        if (programName == "antigelo")
            element.state = "temperatureDisabled"
        else if (programName == "off")
            element.state = "controlsDisabled"
        else
            element.state = ""
    }


    Item {
        id: mainItem
        width: 212
        height: 326
        anchors.fill: parent

        MenuItem {
            id: programItem
            name: qsTr("programma")

            onClicked: {
                element.loadElement("ThermalCentralUnitPrograms.qml", programItem.name, element.dataModel)
                if (programItem.state == "")
                    programItem.state =  "selected"
            }
        }

        Image {
            id: itemTemperature
            anchors.top: programItem.bottom
            anchors.topMargin: 0
            source: "common/comando_bg.png"
            width: element.width
            height: 112
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

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
                y: 68
                width: 24
                height: 10
                color: "#ffffff"
                text: dataModel.temperature / 10 + "°"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
            }

            Image {
                id: minusTemperature
                x: 111
                y: 56
                width: 49
                height: 51
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
                    onClicked: dataModel.temperature -= 5
                }
            }

            Image {
                id: plusTemperature
                x: 160
                y: 56
                width: 49
                height: 51
                source: "common/btn_comando.png"

                Image {
                    id: image3
                    x: 14
                    y: 15
                    source: "common/piu.png"
                }

                MouseArea {
                    id: plusMouseArea
                    anchors.fill: parent
                    onClicked: dataModel.temperature += 5
                }
            }
        }

        Image {
            id: itemMode
            x: 0
            width: element.width
            height: 112
            anchors.top: itemTemperature.bottom
            anchors.topMargin: 0
            source: "common/comando_bg.png"
            property string mode: qsTr("estate")

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            function changeMode() {
                dataModel.mode = (dataModel.mode == ThermalControlUnit99Zones.SummerMode) ?
                            ThermalControlUnit99Zones.WinterMode : ThermalControlUnit99Zones.SummerMode
            }

            Image {
                id: upMode
                x: 111
                y: 56
                width: 49
                height: 51
                source: "common/btn_comando.png"

                Image {
                    id: image7
                    x: 14
                    y: 15
                    source: "common/freccia_up.png"
                }

                MouseArea {
                    id: mouse_area1
                    anchors.fill: parent
                    onClicked: itemMode.changeMode()
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
                font.pixelSize: 13
            }

            Text {
                id: labelMode
                x: 19
                y: 72
                color: "#ffffff"
                text:  dataModel.mode == ThermalControlUnit99Zones.SummerMode ? qsTr("estate") : qsTr("inverno")
                font.pixelSize: 15
            }

            Image {
                id: downMode
                x: 160
                y: 56
                width: 49
                height: 51
                source: "common/btn_comando.png"

                Image {
                    id: image8
                    x: 14
                    y: 15
                    source: "common/freccia_dw.png"
                }

                MouseArea {
                    id: mouse_area2
                    anchors.fill: parent
                    onClicked: itemMode.changeMode()
                }
            }
        }

        ButtonOkCancel {
            id: buttonokcancel
            x: 0
            y: 274
            onCancelClicked: {
                page.showAlert(element, "Modifiche non salvate. Continuare?")
            }

            onOkClicked: {
                element.closeElement()
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

            PropertyChanges {
                target: element
            }
        },
        State {
            name: "controlsDisabled"
            PropertyChanges {
                target: itemTemperature
                opacity: 0.400
            }

            PropertyChanges {
                target: itemMode
                opacity: 0.400
            }

            PropertyChanges {
                target: plusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: minusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: mouse_area2
                enabled: false
            }

            PropertyChanges {
                target: mouse_area1
                enabled: false
            }
        }
    ]

}
