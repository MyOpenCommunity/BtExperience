import QtQuick 1.1
import Components 1.0


ControlSwitch {
    id: control

    property variant loadWithCU

    Component {
        id: forceDurationPopup

        ForceDurationPopup {
            loadWithCU: control.loadWithCU
        }
    }

    upperText: qsTr("Device")
    text: loadWithCU.loadEnabled ? (loadWithCU.loadForced ? qsTr("Not Controlled") : qsTr("Controlled")) : qsTr("Not Enabled")
    pixelSize: 14
    onPressed: loadWithCU.loadEnabled ? (loadWithCU.loadForced ? loadWithCU.stopForcing() : pageObject.installPopup(forceDurationPopup)) : loadWithCU.forceOn()
    status: loadWithCU.loadEnabled ? !loadWithCU.loadForced : 1
}
