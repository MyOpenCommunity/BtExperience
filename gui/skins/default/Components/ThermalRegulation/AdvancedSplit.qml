import QtQuick 1.1
import Components 1.0
import "../../js/logging.js" as Log

MenuElement {
    id: element
    width: 212
    height: programItem.height + modalityItem.height + options.height

    onChildDestroyed: privateProps.currentIndex = -1

    Component.onCompleted: {
        options.setComponent(temperature)
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildLoaded: {
        if (child.modalityChanged)
            child.modalityChanged.connect(modalityChanged)
    }

    MenuItem {
        id: programItem
        name: qsTr("program")
        description: qsTr("morning")
        hasChild: true
        state: privateProps.currentIndex === 1 ? "selected" : ""
        onClicked: {
            if (privateProps.currentIndex !== 1)
                privateProps.currentIndex = 1
            // TODO: this is just to load a page with programs...
            element.loadElement("Components/ThermalRegulation/BasicSplit.qml", name)
        }
    }

    MenuItem {
        id: modalityItem
        anchors.top: programItem.bottom
        name: qsTr("modality")
        description: qsTr("warm")
        hasChild: true
        state: privateProps.currentIndex === 2 ? "selected" : ""
        onClicked: {
            if (privateProps.currentIndex !== 2)
                privateProps.currentIndex = 2
            element.loadElement("Components/ThermalRegulation/AdvancedSplitModalities.qml", name)
        }
    }

    AnimatedLoader {
        id: options
        anchors.bottom: parent.bottom
    }

    function modalityChanged(modality) {
        Log.logDebug("Received modality: " + modality)
        if (modality === "fancoil")
            options.setComponent(fancoil)
        else if (modality === "off" || modality === "deumidificatore")
            options.setComponent(off)
        else
            options.setComponent(temperature)
    }

    Component {
        id: fancoil

        Column {
            ControlUpDown {
                title: qsTr("fancoil")
                text: qsTr("high")
            }
            ControlUpDown {
                title: qsTr("swing")
                text: qsTr("disabled")
            }
            ButtonOkCancel {
            }
        }
    }

    Component {
        id: dehumidifier
        ButtonOkCancel {
        }
    }

    Component {
        id: off

        ButtonOkCancel {
        }
    }

    Component {
        id: temperature
        Column {
            ControlMinusPlus {
                title: qsTr("temperature")
                text: "22 " + qsTr("°C")
            }
            ControlUpDown {
                title: qsTr("fancoil")
                text: qsTr("high")
            }
            ControlUpDown {
                title: qsTr("swing")
                text: qsTr("disabled")
            }
            ButtonOkCancel {
            }
        }
    }
}
