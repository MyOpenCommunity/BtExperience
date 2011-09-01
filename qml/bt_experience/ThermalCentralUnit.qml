import QtQuick 1.0


MenuElement {
    id: element
    width: 192
    height: 300

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
        if (programName == "antigelo")
            element.state = "temperatureDisabled"
        else if (programName == "off")
            element.state = "controlsDisabled"
        else
            element.state = ""
    }

    Item {
        id: mainItem
        anchors.fill: parent

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
                    anchors.right: arrowRight.left
                }

                Image {
                    id: arrowRight
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
                    element.loadChild(text.text, "ThermalCentralUnitPrograms.qml")
                    programItem.state = programItem.state == "" ? "selected" : ""
                }
            }

            states: State {
                name: "selected"
                PropertyChanges { target: text; color: "#ffffff" }
                PropertyChanges { target: currentProgram; color: "#ffffff" }
                PropertyChanges { target: arrowRight; source: "common/freccia_dxS.png" }
                PropertyChanges { target: background; source: "common/tasto_menuS.png" }
            }
        }



        Image {
            id: itemTemperature
            anchors.top: programItem.bottom
            anchors.topMargin: 0
            source: "common/comando_bg.png"
            property int temperature: 22
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
                font.pixelSize: 12
            }

            Text {
                id: labelTemperature
                x: 17
                y: 68
                width: 24
                height: 10
                color: "#ffffff"
                text: itemTemperature.temperature + "°"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }

            Image {
                id: minusTemperature
                x: 101
                y: 50
                source: "common/comando.png"

                Image {
                    id: image4
                    x: 11
                    y: 12
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
                x: 144
                y: 50
                source: "common/comando.png"

                Image {
                    id: image3
                    x: 11
                    y: 12
                    source: "common/piu.png"
                }

                MouseArea {
                    id: plusMouseArea
                    anchors.fill: parent
                    onClicked: itemTemperature.temperature += 1
                }
            }
        }

        Image {
            id: itemMode
            x: 0
            anchors.top: itemTemperature.bottom
            anchors.topMargin: 0
            source: "common/comando_bg.png"
            property string mode: qsTr("estate")

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Image {
                id: upMode
                x: 100
                y: 50
                source: "common/comando.png"

                Image {
                    id: image7
                    x: 11
                    y: 12
                    source: "common/freccia_up.png"
                }

                MouseArea {
                    id: mouse_area1
                    anchors.fill: parent
                    onClicked: itemMode.mode = (itemMode.mode == qsTr("estate")) ? qsTr("inverno") : qsTr("estate")
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
                id: labelMode
                x: 19
                y: 65
                color: "#ffffff"
                text: itemMode.mode
                font.pixelSize: 14
            }

            Image {
                id: downMode
                x: 143
                y: 50
                width: 44
                height: 45
                source: "common/comando.png"

                Image {
                    id: image8
                    x: 11
                    y: 12
                    source: "common/freccia_dw.png"
                }

                MouseArea {
                    id: mouse_area2
                    anchors.fill: parent
                    onClicked: itemMode.mode = (itemMode.mode == qsTr("estate")) ? qsTr("inverno") : qsTr("estate")
                }
            }
        }

        ButtonOkCancel {
            id: buttonokcancel
            x: 0
            y: 251
            anchors.top: itemMode.bottom
            anchors.topMargin: 0
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
