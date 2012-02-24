import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: system
    width: 212
    height: antintrusionColumn.height

    ObjectModel {
        id: objectModel
        categories: [ObjectInterface.Antintrusion]
    }

    Connections {
        target: privateProps.model
        onCurrentScenarioChanged: privateProps.setScenarioDescription()
    }

    function showAlarmLog(name) {
        system.loadElement("AntintrusionAlarms.qml", name, privateProps.model.alarms)
        if (privateProps.currentElement != 1)
            privateProps.currentElement = 1
    }

    Component.onCompleted: privateProps.setScenarioDescription()

    onChildLoaded: {
        if (child.scenarioSelected)
            child.scenarioSelected.connect(privateProps.scenarioSelected)
    }

    onChildDestroyed: {
        privateProps.currentElement = -1
    }

    Timer {
        id: keypadTimer
        repeat: false
        interval: 1000
        running: false
        onTriggered: privateProps.finalizeAction();
    }

    Connections {
        target: privateProps.model
        onNewAlarm: {
            pageObject.showAlarmPopup(alarm.type, alarm.zone, alarm.date_time);
        }
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)

        property bool actionPartialize: false

        property int currentElement: -1

        // 'Public' API
        function scenarioSelected(obj) {
            if (privateProps.model.status === true)
                partialize()
        }

        function toggleActivation(title, errorMessage, okMessage) {
            pageObject.showKeyPad(title, errorMessage, okMessage)
            actionPartialize = false
            connectKeyPad()
        }

        function partialize() {
            pageObject.showKeyPad(qsTr("imposta zone"), qsTr("codice errato"), qsTr("zone impostate"))
            actionPartialize = true
            connectKeyPad()
        }

        function setScenarioDescription() {
            scenarioItem.description = model.currentScenario ? model.currentScenario.name : ""
        }

        // Private API
        // Callbacks for the keypad management
        function connectKeyPad() {
            pageObject.keypadObject.textInsertedChanged.connect(handleTextInserted)
            model.codeAccepted.connect(handleCodeAccepted)
            model.codeRefused.connect(handleCodeRefused)
            model.codeTimeout.connect(handleCodeTimeout)
        }

        function disconnectKeyPad() {
            pageObject.keypadObject.textInsertedChanged.disconnect(handleTextInserted)
            model.codeAccepted.disconnect(handleCodeAccepted)
            model.codeRefused.disconnect(handleCodeRefused)
            model.codeTimeout.disconnect(handleCodeTimeout)
        }

        function handleTextInserted() {
            var keypad = pageObject.keypadObject
            if (keypad.textInserted.length >= 5) {
                if (actionPartialize)
                    model.requestPartialization(keypad.textInserted)
                else
                    model.toggleActivation(keypad.textInserted)
                keypad.state = "disabled"
            }
        }

        function handleCodeAccepted() {
            keypad.state = "ok"
            keypadTimer.start()
        }

        function handleCodeRefused() {
            keypad.state = "error"
            keypadTimer.start()
        }

        function handleCodeTimeout() {
            pageObject.closeKeyPad()
            disconnectKeyPad()
        }

        function finalizeAction() {
            if (pageObject.keypadObject.state === "ok") {
                pageObject.closeKeyPad()
                disconnectKeyPad()
            }
            else
                pageObject.resetKeyPad()
        }
    }

    Column {
        id: antintrusionColumn
        MenuItem {
            active: system.animationRunning === false
            state: privateProps.currentElement == 1 ? "selected" : ""
            name: qsTr("registro allarmi")
            hasChild: true
            onClicked: {
                showAlarmLog(name)
            }
        }
        MenuItem {
            id: systemItem
            active: system.animationRunning === false
            name: qsTr("sistema disattivo")
            hasChild: false
            Image {
                id: systemIcon
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                source: "images/common/ico_sistema_disattivato.png"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var title = system.state === "" ? qsTr("attiva sistema") : qsTr("disattiva sistema")
                    var okMessage = system.state === "" ? qsTr("sistema attivato") : qsTr("sistema disattivato")
                    privateProps.toggleActivation(title, qsTr("codice errato"), okMessage)
                }
            }
        }
        MenuItem {
            id: scenarioItem
            state: privateProps.currentElement == 2 ? "selected" : ""
            active: system.animationRunning === false
            name: qsTr("scenario")
            hasChild: true
            onClicked: {
                system.loadElement("AntintrusionScenarios.qml", name, privateProps.model.scenarios)
                if (privateProps.currentElement != 2)
                    privateProps.currentElement = 2
            }
        }

        Image {
            source: "images/common/bg_zone.png"
            height: zoneText.height + zoneView.height + spacingItem.height

            Rectangle {
                id: zoneDarkRect
                z: 1
                anchors.fill: parent
                color: "black"
                opacity: 0.7
                visible: false
            }

            Text {
                id: zoneText
                height: 50
                text: qsTr("zone")
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                anchors.bottom: zoneView.top
            }

            GridView {
                id: zoneView
                property variant zones: privateProps.model.zones

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: zoneText.bottom
                width: cellWidth * 2
                height: cellHeight * zoneView.zones.size / 2
                interactive: false
                cellWidth: 102
                cellHeight: 50

                delegate: Image {
                    // We need the following trick because the model is not directly editable.
                    // See the comment on ObjectListModel::getObject
                    property variant itemObject: zoneView.zones.getObject(index)
                    source: "images/common/btn_zona.png"
                    Row {
                        anchors.top: parent.top
                        Image {
                            source: itemObject.partialization ? "images/common/off.png" : "images/common/on.png"
                        }
                        Text {
                            text: itemObject.objectId
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: itemObject.name
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: itemObject.partialization = !itemObject.partialization
                    }
                }

                model: zones
            }
            Item {
                id: spacingItem
                height: 5
                anchors.top: zoneView.bottom
            }
        }

        Image {
            source: "images/common/btn_imposta_zone.png"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("imposta zone")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                onClicked: privateProps.partialize()
            }
        }
    }
    states: [
        State {
            name: "systemActive"
            when: privateProps.model.status === true
            PropertyChanges { target: systemItem; name: qsTr("sistema attivo") }
            PropertyChanges { target: systemIcon; source: "images/common/ico_sistema_attivato.png" }
            PropertyChanges { target: zoneDarkRect; visible: true }
            PropertyChanges { target: registerDarkRect; visible: true }
        }
    ]
}
