import QtQuick 1.1
import Components.Text 1.0


Column {
    id: alert
    property alias message: text.text
    property Item source: null
    signal closeAlert
    width: 212

    UbuntuMediumText {
        id: warningText
        text: qsTr("warning")
        color: "#ff2e2e"
        font.capitalization: Font.AllUppercase
        font.pixelSize: 16
    }
    // A kind of spacing
    Item {
        height: 5
        width: parent.width
    }

    Image {
        id: alertBg
        width: parent.width
        height: 130
        source: "../images/home/alert.png"

        UbuntuLightText {
            id: text
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            text: qsTr("")
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
    }

    ButtonOkCancel {
        onOkClicked: {
            source.alertOkClicked()
            source = null
            alert.closeAlert()
        }

        onCancelClicked: {
            if (source.alertCancelClicked)
                source.alertCancelClicked()
            source = null
            alert.closeAlert()
        }
    }
}



