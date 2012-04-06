import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: buttonOnOff.height + sourceItem.height + volume.height
    property string imagesPath: "../../images/"

    Column {
        MenuItem {
            id: sourceItem
            name: "source"
            hasChild: true
            description: "Radio | FM 108.7 - Radio Cassadritta"
            status: -1
            onClicked: element.loadElement("Components/SoundDiffusion/SourceSelection.qml", qsTr("source"))
        }

        Image {
            id: volume
            width: 212
            height: 100
            source: imagesPath + "common/bg_UnaRegolazione.png"

            Text {
                id: text1
                y: 10
                font.pointSize: 12
                font.bold: true
                color: "#444546"
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("volume")
            }

            ButtonMinusPlus {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        ButtonOnOff {
            id: buttonOnOff
            status: false
        }
    }
}
