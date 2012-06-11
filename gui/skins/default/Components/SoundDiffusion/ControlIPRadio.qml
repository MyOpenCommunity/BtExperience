import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log


Image {
    id: control
    width: 212
    height: 100
    property string radioName: "Radio 24"
    property string imagesPath: "../../images/"

    source: imagesPath + "common/bg_UnaRegolazione.png"

    Row {
        anchors {
            bottom: control.bottom
            bottomMargin: 5
            horizontalCenter: control.horizontalCenter
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/precedente.png"
            onClicked: Log.logDebug("Prev clicked")
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/play.png"
            onClicked: Log.logDebug("Play clicked")
        }

        ButtonMediaControl {
            insideImage:imagesPath + "common/successivo.png"
            onClicked: Log.logDebug("Next clicked")
        }
    }

    UbuntuLightText {
        id: text1
        y: 10
        anchors.horizontalCenter: control.horizontalCenter
        text: control.radioName
        font.bold: true
        font.pixelSize: 16
        color: "#444546"
    }
}
