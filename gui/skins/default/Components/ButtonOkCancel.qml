import QtQuick 1.1


SvgImage {
    id: control

    signal okClicked
    signal cancelClicked

    source: "../images/termo/ok-cancel/bg_ok-cancel.svg"

    ButtonThreeStates {
        id: okButton

        defaultImage: "../images/termo/ok-cancel/btn_ok-cancel.svg"
        pressedImage: "../images/termo/ok-cancel/btn_ok-cancel_P.svg"
        selectedImage: "../images/termo/ok-cancel/btn_ok-cancel_S.svg"
        shadowImage: "../images/termo/ok-cancel/ombra_btn_ok-cancel.svg"
        text: qsTr("ok")
        font.pixelSize: 14
        onClicked: control.okClicked()
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 7
        }
    }

    ButtonThreeStates {
        id: cancelButton

        defaultImage: "../images/termo/ok-cancel/btn_ok-cancel.svg"
        pressedImage: "../images/termo/ok-cancel/btn_ok-cancel_P.svg"
        selectedImage: "../images/termo/ok-cancel/btn_ok-cancel_S.svg"
        shadowImage: "../images/termo/ok-cancel/ombra_btn_ok-cancel.svg"
        text: qsTr("cancel")
        font.pixelSize: 14
        onClicked: control.cancelClicked()
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 7
        }
    }
}
