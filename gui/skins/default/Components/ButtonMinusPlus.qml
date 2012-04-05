import QtQuick 1.1

TwoButtonsSettings {
    id: button
    leftImage: "../images/common/meno.png"
    rightImage: "../images/common/piu.png"

    signal plusClicked
    signal minusClicked

    onLeftClicked: button.minusClicked()
    onRightClicked: button.plusClicked()
}

