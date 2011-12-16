import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: fixedItem.height + (itemLoader.sourceComponent !== null ? itemLoader.height : 0)

    function alertOkClicked() {
        element.closeElement()
    }

    function okClicked() {
        closeElement();
    }

    function cancelClicked() {
        page.showAlert(element, "Modifiche non salvate. Continuare?")
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    Component.onCompleted: showProgram()

    function showProgram() {
        var desc = "";
        switch (dataModel.probeStatus) {
        case ThermalControlledProbe.Auto:
            itemLoader.changeComponent(autoComponent)
            desc = "auto"
            break
        case ThermalControlledProbe.Antifreeze:
            itemLoader.changeComponent(antifreezeComponent)
            desc = "antigelo"
            break
        case ThermalControlledProbe.Manual:
            itemLoader.changeComponent(manualComponent)
            desc = "manuale"
            break
        case ThermalControlledProbe.Off:
            itemLoader.changeComponent(offComponent)
            desc = "off"
            break
        }
        programItem.description = desc
    }

    Connections {
        target: dataModel
        onProbeStatusChanged: showProgram()
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
        id: offComponent
        ButtonOkCancel {
            onCancelClicked: element.cancelClicked();
            onOkClicked: element.okClicked();
        }
    }

    Component {
        id: antifreezeComponent
        ButtonOkCancel {
            onCancelClicked: element.cancelClicked();
            onOkClicked: element.okClicked();
        }
    }

    Component {
        id: autoComponent
        Column {
            ControlUpDown {
                title: qsTr("velocità fancoil")
                text: "alta"
            }

            ButtonOkCancel {
                onCancelClicked: element.cancelClicked();
                onOkClicked: element.okClicked();
            }
        }
    }

    Component {
        id: manualComponent
        Column {
            ControlMinusPlus {
                title: qsTr("temperatura impostata")
                text: dataModel.setpoint / 10 + qsTr("° C")
                onPlusClicked: dataModel.setpoint += 1
                onMinusClicked: dataModel.setpoint -= 1
            }

            ControlUpDown {
                title: qsTr("velocità fancoil")
                text: "alta"
            }

            ButtonOkCancel {
                onCancelClicked: element.cancelClicked();
                onOkClicked: element.okClicked();
            }
        }
    }

    Loader {
        id: itemLoader
        anchors.top: fixedItem.bottom

        property variant _pendingComponent: undefined

        function changeComponent(newComponent) {
            _pendingComponent = newComponent
            if (sourceComponent !== null)
                opacity = 0 // implictly use the Connections object
            else
                _showComponent()
        }

        Connections {
            target: opacityanimation
            onRunningChanged: {
                if (opacityanimation.running) // at the end of the animation
                    return
                // if there is a pending component, we show it
                if (itemLoader._pendingComponent !== undefined)
                    itemLoader._showComponent()
            }
        }

        function _showComponent() {
            opacity = 1
            sourceComponent = _pendingComponent
            _pendingComponent = undefined
        }

        Behavior on opacity {
            NumberAnimation {
                id: opacityanimation
                duration: 200
            }
        }
    }
}

