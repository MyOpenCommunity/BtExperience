import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property variant load
    property bool showCurrency

    source: "../../images/common/bg_on-off.svg"
    height: 40

    Row {
        anchors.centerIn: parent

        ButtonThreeStates {
            id: moneyButton

            font.pixelSize: 14
            defaultImage: "../../images/common/btn_66x35.svg"
            pressedImage: "../../images/common/btn_66x35_P.svg"
            selectedImage: "../../images/common/btn_66x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_66x35.svg"
            text: load.rate.currencySymbol
            status: showCurrency === true ? 1 : 0
            onClicked: showCurrency = true
            enabled: load.rate !== null
        }

        ButtonThreeStates {
            id: consumptionButton

            font.pixelSize: 14
            defaultImage: "../../images/common/btn_66x35.svg"
            pressedImage: "../../images/common/btn_66x35_P.svg"
            selectedImage: "../../images/common/btn_66x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_66x35.svg"
            text: load.cumulativeUnit
            status: showCurrency === false ? 1 : 0
            onClicked: showCurrency = false
        }
    }
}
