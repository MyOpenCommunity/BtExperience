import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: system

    ObjectModel {
        id: objectModel
        categories: [ObjectInterface.Antintrusion]
    }

    Timer {
        id: keypadTimer
        repeat: false
        interval: 1000
        running: false
        onTriggered: privateProps.finalizeAction();
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)

        property bool actionPartialize: false

        // Callbacks for the keypad management
        function connectCallbacks() {
            pageObject.keypadObject.textInsertedChanged.connect(handleTextInserted)
            model.codeRefused.connect(handleCodeRefused)
        }

        function disconnectCallbacks() {
            pageObject.keypadObject.textInsertedChanged.disconnect(handleTextInserted)
            model.codeAccepted.disconnect(handleCodeAccepted)
            model.codeRefused.disconnect(handleCodeRefused)
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

        function finalizeAction() {
            if (pageObject.keypadObject.state === "ok") {
                pageObject.closeKeyPad()
                disconnectCallbacks()
            }
            else
                pageObject.resetKeyPad()
        }
    }

    Column {
        MenuItem {
            name: qsTr("registro allarmi")
            hasChild: true

            Rectangle {
                id: registerDarkRect
                z: 1
                anchors.fill: parent
                color: "black"
                opacity: 0.7
                visible: false
            }
        }
        MenuItem {
            id: systemItem
            name: qsTr("sistema disattivo")
            hasChild: false
            Image {
                id: systemIcon
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                source: "images/common/ico_sistema_disattivato.png"
                states: [
                    State {
                        name: "active"
                        PropertyChanges { target: systemIcon; source: "images/common/ico_sistema_attivato.png" }
                    }
                ]
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var title = systemIcon.state === "" ? qsTr("attiva sistema") : qsTr("disattiva sistema")
                    pageObject.showKeyPad(title)
                    privateProps.actionPartialize = false
                    privateProps.connectCallbacks()
                }
            }
        }
        MenuItem {
            name: qsTr("scenario")
            description: qsTr("giorno")
            hasChild: true
        }

        Image {
            source: "images/common/bg_zone.png"

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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                width: cellWidth * 2
                height: cellHeight * 4
                interactive: false
                cellWidth: 102
                cellHeight: 50

                delegate: Image {
                    // We need the following trick because the model is not directly editable.
                    // See the comment on ObjectListModel::getObject
                    property variant dataModel: privateProps.model.zones.getObject(index)
                    source: "images/common/btn_zona.png"
                    Row {
                        anchors.top: parent.top
                        Image {
                            source: dataModel.partialization ? "images/common/off.png" : "images/common/on.png"
                        }
                        Text {
                            text: dataModel.objectId
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: dataModel.name
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: dataModel.partialization = !dataModel.partialization
                    }
                }

                model: objectModel.getObject(0).zones
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
                onClicked: {
                    pageObject.showKeyPad(qsTr("imposta zone"))
                    privateProps.actionPartialize = true
                    privateProps.connectCallbacks()
                }
            }
        }
    }
    states: [
        State {
            name: "systemActive"
            PropertyChanges { target: systemItem; name: qsTr("sistema attivo") }
            PropertyChanges { target: systemIcon; source: "images/common/ico_sistema_attivato.png" }
            PropertyChanges { target: zoneDarkRect; visible: true }
            PropertyChanges { target: registerDarkRect; visible: true }
        }
    ]
}
