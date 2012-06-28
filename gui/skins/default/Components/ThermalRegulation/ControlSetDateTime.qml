import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property string date
    property string time
    property alias status: buttonEdit.status
    property bool dateVisible: true

    signal editClicked

    source: "../../images/termo/imposta_data-ora/bg_imposta_data-ora.svg"

    UbuntuLightText {
        id: labelDate
        visible: control.dateVisible
        color: "black"
        text: qsTr("until date")
        font.pixelSize: 13
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: valueDate
        visible: control.dateVisible
        color: "white"
        text: control.date
        font.pixelSize: 14
        anchors {
            top: labelDate.bottom
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: labelTime
        color: "black"
        text: qsTr("until time")
        font.pixelSize: 13
        anchors {
            top: control.dateVisible ? valueDate.bottom : parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: valueTime
        color: "white"
        text: control.time
        font.pixelSize: 14
        anchors {
            top: labelTime.bottom
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    ButtonImageThreeStates {
        id: buttonEdit
        z: 1
        anchors {
            right: parent.right
            rightMargin: 7
            bottom: parent.bottom
            bottomMargin: 5
        }

        defaultImageBg: "../../images/termo/imposta_data-ora/btn_imposta_data-ora.svg"
        pressedImageBg: "../../images/termo/imposta_data-ora/btn_imposta_data-ora_P.svg"
        selectedImageBg: "../../images/termo/imposta_data-ora/btn_imposta_data-ora_S.svg"
        shadowImage: "../../images/termo/imposta_data-ora/ombra_btn_imposta_data-ora.svg"
        defaultImage: "../../images/termo/imposta_data-ora/ico_imposta_data-ora.svg"
        pressedImage: "../../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg"
        selectedImage: "../../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg" // we don't have a _S version
        status: 0
        onClicked: control.editClicked()
    }
}
