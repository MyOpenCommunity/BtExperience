import QtQuick 1.1


SvgImage {
    id: control

    signal okClicked
    signal cancelClicked

    source: "../images/common/panel_212x50.svg"

    ButtonThreeStates {
        id: okButton

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
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

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
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
