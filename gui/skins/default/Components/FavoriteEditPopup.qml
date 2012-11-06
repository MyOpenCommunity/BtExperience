import QtQuick 1.1
import Components.Text 1.0


Item {
    width: background.width
    height: background.height
    property variant favoriteItem: undefined

    signal closePopup

    onFavoriteItemChanged: {
        if (favoriteItem !== undefined)
        {
            addressInput.text = favoriteItem.address
            descriptionInput.text = favoriteItem.name
        }
    }

    Image {
        id: background
        width: 300
        height: 250
        source: "../images/common/bg_tastiera_codice.png"
    }


    UbuntuLightText {
        id: header
        text: qsTr("Edit favorite item")
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: background.horizontalCenter
    }

    UbuntuLightText {
        id: addressText
        text: qsTr("Address:")
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: header.bottom
        anchors.topMargin: 10
    }

    Item {
        id: addressRow
        height: rect.height
        anchors.top: addressText.bottom
        anchors.topMargin: 10
        anchors.left: background.left
        anchors.leftMargin: 10
        anchors.right: background.right
        anchors.rightMargin: 10

        Rectangle {
            id: rect
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
            UbuntuLightTextInput {
                id: addressInput
                anchors.fill: parent
                activeFocusOnPress: false
                text: "www.corriere.it"
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

    UbuntuLightText {
        id: titleText
        text: qsTr("Favorite label:")
        anchors.top: addressRow.bottom
        anchors.topMargin: 15
        anchors.left: parent.left
        anchors.leftMargin: 10
    }

    Rectangle {
        anchors.top: titleText.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: 20
        UbuntuLightTextInput {
            id: descriptionInput
            anchors.fill: parent
            activeFocusOnPress: false
            text: "www.corriere.it"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                descriptionInput.forceActiveFocus()
                descriptionInput.openSoftwareInputPanel()
            }
        }
    }

    Row {
        spacing: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10

        Image {
            id: buttonOk
            source: "../images/common/btn_OKAnnulla.png"

            UbuntuLightText {
                anchors.centerIn: parent
                text: qsTr("ok")
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Confirm editing")
                    favoriteItem.name = descriptionInput.text
                    favoriteItem.address = addressInput.text
                    closePopup()
                }
            }
        }

        Image {
            id: buttonCancel
            source: "../images/common/btn_OKAnnulla.png"

            UbuntuLightText {
                anchors.centerIn: parent
                text: qsTr("cancel")
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Discard editing")
                    closePopup()
                }
            }
        }
    }
}
