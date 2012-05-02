import QtQuick 1.1


Image {
    id: control
    width: 212
    height: 75
    source: "../images/common/bg_UnaRegolazione.png"

    property alias line1: line1.text
    property alias line2: line2.text
    property alias line3: line3.text
    property alias text: caption.text
    signal clicked()

    Text {
        id: line1
        text: qsTr("line1")
        font {
            bold: true
            pixelSize: 12
        }
        anchors {
            top: control.top
            topMargin: 10
            left: control.left
            leftMargin: 10
        }
    }

    Text {
        id: line2
        text: qsTr("line2")
        font {
            bold: false
            pixelSize: 12
        }
        anchors {
            top: line1.bottom
            topMargin: 5
            left: control.left
            leftMargin: 10
        }
        wrapMode: Text.WordWrap
    }

    Text {
        id: line3
        text: qsTr("line3")
        color: "white"
        font {
            bold: false
            pixelSize: 12
        }
        anchors {
            top: line2.bottom
            topMargin: 5
            left: control.left
            leftMargin: 10
        }
        wrapMode: Text.WordWrap
    }

    Image {
        id: button
        width: 75
        source: "../images/common/btn_comando.png"
        anchors {
            top: control.top
            bottom: control.bottom
            right: control.right
            topMargin: 10
            bottomMargin: 10
            rightMargin: 5
        }

        Text {
            id: caption
            text: qsTr("caption")
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            font.capitalization: Font.AllUppercase
        }

        MouseArea {
            anchors.fill: parent
            onClicked: control.clicked()
        }
    }
}

