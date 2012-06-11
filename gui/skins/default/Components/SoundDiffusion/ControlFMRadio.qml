import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log


Image {
    id: control
    width: 212
    height: 100
    property string imagesPath: "../../images/"
    property string radioName: "Radio Cassadritta"
    property int radioFrequency: 10870

    signal nextTrack
    signal previousTrack

    source: imagesPath + "common/bg_UnaRegolazione.png"

    Row {
        anchors {
            bottom: control.bottom
            bottomMargin: 5
            right: control.right
            rightMargin: 5
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/precedente.png"
            onClicked: control.previousTrack()
        }

        ButtonMediaControl {
            insideImage: imagesPath + "common/successivo.png"
            onClicked: control.nextTrack()
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

    UbuntuLightText {
        id: text2
        x: 15
        y: 62
        text: formatFrequency(control.radioFrequency)
        font.pixelSize: 16
        color: "white"
    }

    function formatFrequency(freq) {
        if (freq === -1)
            return "FM --.-"
        else
        {
            var s = "FM " + freq
            // add a dot "." before the last two digits
            return s.slice(0, s.length - 2) + "." + s.slice(s.length - 2)
        }
    }
}
