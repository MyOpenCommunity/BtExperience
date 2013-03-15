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

    upperText: qsTr("Control")
    text: loadWithCU.loadForced ? qsTr("Disabled") : qsTr("Enabled")
    pixelSize: 14
    onPressed: loadWithCU.loadForced ? loadWithCU.stopForcing() : pageObject.installPopup(forceDurationPopup)
    status: loadWithCU.loadForced
}
