import QtQuick 1.0


Column {
    id: alert
    property alias message: text.text
    property Item source: null
    signal hideAlert

    Text {
        id: warningText
        text: qsTr("ATTENZIONE")
        color: "#ff2e2e"
        font.family: semiBoldFont.name
        font.pixelSize: 16
    }
    // A kind of spacing
    Item {
        height: 5
        width: parent.width
    }

    Image {
        id: alertBg
        source: "alert.png"

        Text {
            id: text
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            text: qsTr("")
            font.family: regularFont.name
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
    }

    ButtonOkCancel {
        onOkClicked: {
            source.alertOkClicked()
            source = null
            alert.hideAlert()
        }

        onCancelClicked: {
            source.alertCancelClicked()
            source = null
            alert.hideAlert()
        }
    }
}



