import QtQuick 1.1
import Components.Text 1.0


Column {
    id: popup

    property alias title: popupTitle.text
    property alias topInputLabel: titleText.text
    property alias topInputText: descriptionInput.text
    property alias bottomInputLabel: addressText.text
    property alias bottomInputText: addressInput.text
    property bool bottomInputIsPassword: false
    property variant favoriteItem: undefined

    signal closePopup

    function okClicked() {
        if (favoriteItem) {
            favoriteItem.name = descriptionInput.text
            if (favoriteItem.address)
                favoriteItem.address = addressInput.text
        }
    }

    function cancelClicked() {
    }

    spacing: 4

    onFavoriteItemChanged: {
        if (favoriteItem !== undefined)
        {
            descriptionInput.text = favoriteItem.name
            if (favoriteItem.address) {
                addressInput.text = favoriteItem.address
            }
            else {
                addressInputBg.visible = false
                addressText.visible = false
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
            id: popupTitle
            text: qsTr("Edit quicklink properties")
            font.pixelSize: 24
            color: "white"
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_testo.svg"

        Column {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
            }

            spacing: 3

            UbuntuLightText {
                id: titleText
                font.pixelSize: 14
                color: "white"
                text: qsTr("Title:")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SvgImage {
                source: "../images/common/bg_text-input.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                UbuntuLightTextInput {
                    id: descriptionInput
                    text: "Title goes here."
                    font.pixelSize: 14
                    color: "#5A5A5A"
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    activeFocusOnPress: false
                    containerWidget: popup
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        descriptionInput.forceActiveFocus()
                        descriptionInput.openSoftwareInputPanel()
                    }
                }
            }

            UbuntuLightText {
                id: addressText
                font.pixelSize: 14
                color: "white"
                text: qsTr("Address:")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SvgImage {
                id: addressInputBg
                source: "../images/common/bg_text-input.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                UbuntuLightTextInput {
                    id: addressInput
                    text: "Address goes here."
                    font.pixelSize: 14
                    color: "#5A5A5A"
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    activeFocusOnPress: false
                    containerWidget: popup
                    echoMode: popup.bottomInputIsPassword ? TextInput.Password : TextInput.Normal
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addressInput.forceActiveFocus()
                        addressInput.openSoftwareInputPanel()
                    }
                }
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_ok_annulla.svg"

        Row {
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("ok")
                font.pixelSize: 14
                onClicked: {
                    popup.okClicked()
                    closePopup()
                }
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("cancel")
                font.pixelSize: 14
                onClicked: {
                    popup.cancelClicked()
                    popup.closePopup()
                }
            }
        }
    }
}
