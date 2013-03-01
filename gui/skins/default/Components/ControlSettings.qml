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

    source: "../images/common/bg_panel_212x100.svg"

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
        width: parent.width / 100 * 90
        elide: Text.ElideRight
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
        width: parent.width / 100 * 90
        elide: Text.ElideRight
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
        width: parent.width / 100 * 90
        elide: Text.ElideRight
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
        width: parent.width / 100 * 90
        elide: Text.ElideRight
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

        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        selectedImageBg: "../images/common/btn_66x35_S.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora.svg"
        pressedImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg"
        selectedImage: "../images/termo/imposta_data-ora/ico_imposta_data-ora_P.svg" // we don't have a _S version
        onClicked: control.editClicked()
    }
}

