import QtQuick 1.1
import Components 1.0


Column {
    id: control

    property variant loadWithCU

    signal closePopup

    ControlMinusPlus {
        title: qsTr("Force load")
        text: format(loadWithCU.forceDuration)
        onMinusClicked: loadWithCU.decreaseForceDuration()
        onPlusClicked: loadWithCU.increaseForceDuration()
        Component.onCompleted: loadWithCU.resetForceDuration()

        function format(minutes) {
            var h = Math.floor(minutes / 60)
            if (h < 10)
                h = "0" + h
            var m = minutes % 60
            if (m < 10)
                m = "0" + m
            return qsTr("Time") + ": " + h + ":" + m
        }
    }

    SvgImage {
        source: "../../images/common/bg_on-off.svg"

        ButtonThreeStates {
            id: buttonForce

            defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
            pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
            shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
            text: qsTr("force load")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 15
            onClicked: {
                loadWithCU.forceOn(loadWithCU.forceDuration)
                control.closePopup()
            }
            anchors.centerIn: parent
        }
    }
}
