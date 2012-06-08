import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: antintrusionColumn.height
    property string alarmLogTitle: qsTr("alarm log")
    property string imagesPath: "../../images/"

    Component {
        id: antintrusionAlarms
        AntintrusionAlarms {}
    }

    Component {
        id: antinstrusionScenarios
        AntintrusionScenarios {}
    }

    ObjectModel {
        id: objectModel
        source: myHomeModels.myHomeObjects
        filters: [{objectId: ObjectInterface.IdAntintrusionSystem}]
    }

    Connections {
        target: privateProps.model
        onCurrentScenarioChanged: privateProps.setScenarioDescription()
    }

    function showAlarmLog(name) {
        column.loadColumn(antintrusionAlarms, column.alarmLogTitle, privateProps.model.alarms)
        if (privateProps.currentElement != 1) {
            privateProps.currentElement = 1
        }
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
            pageObject.showKeyPad(qsTr("modify zones"), qsTr("wrong code"), qsTr("zone settings"))
            actionPartialize = true
            connectKeyPad()
        }

        function setScenarioDescription() {
            scenarioItem.description = model.currentScenario ? model.currentScenario.name : ""
        }

        // Private API
        // Callbacks for the keypad management
        function connectKeyPad() {
            popupLoader.item.textInsertedChanged.connect(handleTextInserted)
            model.codeAccepted.connect(handleCodeAccepted)
            model.codeRefused.connect(handleCodeRefused)
            model.codeTimeout.connect(handleCodeTimeout)
        }

        function handleTextInserted() {
            var keypad = popupLoader.item
            if (keypad.textInserted.length >= 5) {
                if (actionPartialize)
                    model.requestPartialization(keypad.textInserted)
                else
                    model.toggleActivation(keypad.textInserted)
                keypad.state = "disabled"
            }
        }

        // Callbacks called from the model
        function handleCodeAccepted() {
            popupLoader.item.state = "ok"
            keypadTimer.start()
        }

        function handleCodeRefused() {
            popupLoader.item.state = "error"
            keypadTimer.start()
        }

        function handleCodeTimeout() {
            pageObject.closeKeyPad()
        }

        function finalizeAction() {
            if (popupLoader.item.state === "ok") {
                pageObject.closeKeyPad()
            }
            else
                pageObject.resetKeyPad()
        }
    }

    Column {
        id: antintrusionColumn
        MenuItem {
            id: systemItem

            backgroundImage: "../../images/common/panel_switch.svg"
            name: qsTr("system")
            description: qsTr("disabled")
            hasChild: false

            MouseArea {
                anchors.fill: parent
            }

            AntintrusionSwitch {
                id: systemIcon
                anchors.right: parent.right
                anchors.rightMargin: width / 100 * 10
                anchors.verticalCenter: parent.verticalCenter
                status: 1
                onClicked: {
                    var title = column.state === "" ? qsTr("enable system") : qsTr("disable system")
                    var okMessage = column.state === "" ? qsTr("system enabled") : qsTr("system disabled")
                    privateProps.toggleActivation(title, qsTr("wrong code"), okMessage)
                }
            }
        }
        MenuItem {
            property int numberOfAlarms: privateProps.model.alarms.count
            state: privateProps.currentElement == 1 ? "selected" : ""
            name: column.alarmLogTitle
            hasChild: true
            onClicked: showAlarmLog()
            boxInfoState: numberOfAlarms > 0 ? "warning" : ""
            boxInfoText: numberOfAlarms

            Rectangle {
                id: registerDarkRect
                z: 1
                anchors.fill: parent
                color: "black"
                opacity: 0.7
                visible: false
                MouseArea { anchors.fill: parent } // block the mouse clicks
            }
        }
        MenuItem {
            id: scenarioItem
            state: privateProps.currentElement == 2 ? "selected" : ""
            name: qsTr("scenario")
            hasChild: true
            onClicked: {
                column.loadColumn(antinstrusionScenarios, name, privateProps.model.scenarios)
                if (privateProps.currentElement != 2)
                    privateProps.currentElement = 2
            }
        }


        SvgImage {
            source: "../../images/common/panel_zones.svg"
            height: zoneText.height + zoneView.height + buttonZones.height

            Rectangle {
                id: zoneDarkRect
                z: 1
                anchors.fill: parent
                color: "black"
                opacity: 0.7
                visible: false
                MouseArea { anchors.fill: parent } // block the mouse clicks
            }

            Text {
                id: zoneText
                text: qsTr("zone")
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors.top: parent.top
                anchors.topMargin: parent.height / 100 * 1
                anchors.horizontalCenter: parent.horizontalCenter
                width: zoneView.width
            }

            GridView {
                id: zoneView

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: zoneText.bottom
                anchors.topMargin: parent.height / 100 * 2
                width: cellWidth * 2
                height: 200 // (cellHeight * zoneModel.count / 2) // Why it does not work???
                interactive: false
                cellWidth: 99
                cellHeight: 47

                delegate: ButtonThreeStates {
                    id: zoneButton
                    // We need the following trick because the model is not directly editable.
                    // See the comment on MediaModel::getObject
                    property variant itemObject: zoneModel.getObject(index)

                    LedZone {
                        id: led
                        text: itemObject.number
                        status: itemObject.partialization ? 0 : 1
                        anchors {
                            top: parent.top
                            left: parent.left
                            topMargin: parent.height / 100 * 12 // manual alignment to center the image with the text
                            leftMargin: parent.width / 100 * 6
                        }
                    }

                    textAnchors.centerIn: null
                    textAnchors.top: zoneButton.top
                    textAnchors.topMargin: zoneButton.height / 100 * 6
                    textAnchors.left: led.right
                    textAnchors.leftMargin: zoneButton.width / 100 * 6
                    textAnchors.right: zoneButton.right
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignLeft
                    defaultImage: "../images/common/button_zones.svg"
                    pressedImage: "../images/common/button_zones_press.svg"
                    selectedImage: "../images/common/button_zones_select.svg"
                    shadowImage: "../images/common/shadow_button_zones.svg"
                    text: itemObject.name
                    onClicked: itemObject.partialization = !itemObject.partialization
                    status: itemObject.partialization ? 0 : 1
                }

                ObjectModel {
                    id: zoneModel
                    source: privateProps.model.zones
                }
                model: zoneModel

            }

            ButtonThreeStates {
                id: buttonZones
                defaultImage: "../images/common/button_set-zones.svg"
                pressedImage: "../images/common/button_set-zones_press.svg"
                selectedImage: "../images/common/button_set-zones_select.svg"
                shadowImage: "../images/common/shadow_button_set-zones.svg"
                text: qsTr("modify zones")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                onClicked: privateProps.partialize()
                status: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 100 * 3
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    states: [
        State {
            name: "systemActive"
            when: privateProps.model.status === true
            PropertyChanges { target: systemItem; name: qsTr("system enabled") }
            PropertyChanges { target: systemIcon; status: 0 }
            PropertyChanges { target: zoneDarkRect; visible: true }
            PropertyChanges { target: registerDarkRect; visible: true }
        }
    ]
}
