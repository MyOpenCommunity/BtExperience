import QtQuick 1.1
import Components.Text 1.0


Column {
    id: popup

    property variant favoriteItem: undefined

    signal closePopup

    spacing: 4

    onFavoriteItemChanged: {
        if (favoriteItem !== undefined)
        {
            addressInput.text = favoriteItem.address
            descriptionInput.text = favoriteItem.name
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
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
                    text: qsTr("Title goes here.")
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
                source: "../images/common/bg_text-input.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                UbuntuLightTextInput {
                    id: addressInput
                    text: qsTr("Address goes here.")
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
                    favoriteItem.name = descriptionInput.text
                    favoriteItem.address = addressInput.text
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
                    closePopup()
                }
            }
        }
    }
}
