import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property string upperLabel
    property string upperText
    property bool upperLabelVisible: true
    property string bottomLabel
    property string bottomText

    property alias status: buttonEdit.status
    property alias bottomTextFormat: textBottomText.textFormat

    signal editClicked

    // TODO: here and below, move the images in the common path!
    source: "../images/termo/imposta_data-ora/bg_imposta_data-ora.svg"

    UbuntuLightText {
        id: textUpperLabel
        visible: control.upperLabelVisible
        color: "black"
        text: control.upperLabel
        font.pixelSize: 15
        anchors {
            // TODO: use margins in percentage!
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: textUpperText
        visible: control.upperLabelVisible
        color: "white"
        text: control.upperText
        font.pixelSize: 14
        anchors {
            top: textUpperLabel.bottom
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: textBottomLabel
        color: "black"
        text: control.bottomLabel
        font.pixelSize: 15
        anchors {
            top: control.upperLabelVisible ? textUpperText.bottom : parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    UbuntuLightText {
        id: textBottomText
        color: "white"
        text: control.bottomText
        font.pixelSize: 14
        anchors {
            top: textBottomLabel.bottom
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
            bottomMargin: control.upperLabelVisible ? 5 : 10
        }

        // TODO: see the TODO above
        defaultImageBg: "../images/termo/imposta_data-ora/btn_imposta_data-ora.svg"
        pressedImageBg: "../images/termo/imposta_data-ora/btn_imposta_data-ora_P.svg"
        selectedImageBg: "../images/termo/imposta_data-ora/btn_imposta_data-ora_S.svg"
        shadowImage: "../images/termo/imposta_data-ora/ombra_btn_imposta_data-ora.svg"
        defaultImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora.svg"
        pressedImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg"
        selectedImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg" // we don't have a _S version
        status: 0
        onClicked: control.editClicked()
    }
}

