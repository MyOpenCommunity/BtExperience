import QtQuick 1.1
import Components 1.0


Column {
    id: control

    property variant loadWithCU

    ControlMinusPlus {
        title: qsTr("Force load")
        text: loadWithCU.forceDuration + qsTr(" minutes")
        onMinusClicked: loadWithCU.decreaseForceDuration()
        onPlusClicked: loadWithCU.increaseForceDuration()
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
            onClicked: loadWithCU.forceOn(loadWithCU.forceDuration)
            anchors.centerIn: parent
        }
    }
}
