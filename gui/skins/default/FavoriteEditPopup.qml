import QtQuick 1.1

Item {
    width: background.width
    height: background.height

    signal closePopup

    Image {
        id: background
        width: 300
        height: 200
        source: "images/common/bg_tastiera_codice.png"
    }


    Text {
        id: header
        text: qsTr("Edit favorite item:")
        anchors.horizontalCenter: background.horizontalCenter
    }

    Text {
        id: addressText
        text: qsTr("Address:")
        anchors.top: header.bottom
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

        Text {
            id: httpText
            text: "http://"
            anchors.left: parent.left
        }

        Rectangle {
            id: rect
            anchors.left: httpText.right
            anchors.right: parent.right
            height: 20
            TextInput {
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

    Text {
        id: titleText
        text: qsTr("Favorite label:")
        anchors.top: addressRow.bottom
        anchors.topMargin: 15
    }

    Rectangle {
        anchors.top: titleText.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: 20
        TextInput {
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
        spacing: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: buttonOk
            source: "images/common/btn_OKAnnulla.png"

            Text {
                anchors.centerIn: parent
                text: qsTr("ok")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Confirm editing")
                    closePopup()
                }
            }
        }

        Image {
            id: buttonCancel
            source: "images/common/btn_OKAnnulla.png"

            Text {
                anchors.centerIn: parent
                text: qsTr("cancel")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Discard editing")
                    closePopup()
                }
            }
        }
    }
}
