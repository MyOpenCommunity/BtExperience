import QtQuick 1.1


Image {
    id: bg

    property int textMargin: 25
    property string text: "TEXT"

    signal clicked

    source: "../images/common/bg_DueRegolazioni.png"
    visible: source === "" ? false : true

    UbuntuLightText {
        text: bg.text
        anchors {
            fill: parent
            leftMargin: bg.textMargin
        }
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font {
            pointSize: 10
            capitalization: Font.AllUppercase
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: bg.clicked()
    }
}
