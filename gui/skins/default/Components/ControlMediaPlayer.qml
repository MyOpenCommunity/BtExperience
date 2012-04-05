import QtQuick 1.1
import "../js/logging.js" as Log

Image {
    id: control
    width: 212
    height: 100
    property string songTitle: "1.45 - Traccia 1 - Artista 1"

    source: "../images/common/bg_UnaRegolazione.png"

    Row {
        anchors {
            bottom: control.bottom
            right: control.right
            rightMargin: 5
            bottomMargin: 5
        }
        ButtonMediaControl {
            insideImage: "../images/common/precedente.png"
            onClicked: Log.logDebug("Prev clicked")
        }

        ButtonMediaControl {
            insideImage: "../images/common/stop.png"
            onClicked: Log.logDebug("Stop clicked")
        }

        ButtonMediaControl {
            insideImage: "../images/common/play.png"
            onClicked: Log.logDebug("Play clicked")
        }

        ButtonMediaControl {
            insideImage: "../images/common/successivo.png"
            onClicked: Log.logDebug("Next clicked")
        }
    }

    Text_12pt_bold {
        id: text1
        y: 10
        anchors.horizontalCenter: control.horizontalCenter
        text: control.songTitle
    }
}
