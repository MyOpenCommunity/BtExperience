import QtQuick 1.1
import Components.SoundDiffusion 1.0


SystemPage {
    id: sounddiffusion
    source: "images/sound-diffusion.jpg"
    text: qsTr("Sound System")
    rootColumn: Component { SoundDiffusionSystem {} }
}

