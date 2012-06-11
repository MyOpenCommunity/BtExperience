import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log


Image {
    id: control
    width: 212
    height: 100
    property string songTitle: "1.45 - Traccia 1 - Artista 1"
    property string imagesPath: "../../images/"

    source: imagesPath + "common/bg_UnaRegolazione.png"

    Row {
        anchors {
            bottom: control.bottom
            right: control.right
            rightMargin: 5
            bottomMargin: 5
        }
        ButtonMediaControl {
            insideImage: imagesPath + "common/precedente.png"
            onClicked: Log.logDebug("Prev clicked")
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/stop.png"
            onClicked: Log.logDebug("Stop clicked")
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/play.png"
            onClicked: Log.logDebug("Play clicked")
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/successivo.png"
            onClicked: Log.logDebug("Next clicked")
        }
    }

    UbuntuLightText {
        id: text1
        y: 10
        anchors.horizontalCenter: control.horizontalCenter
        text: control.songTitle
        font.bold: true
        font.pixelSize: 12
        color: "#444546"
    }
}
