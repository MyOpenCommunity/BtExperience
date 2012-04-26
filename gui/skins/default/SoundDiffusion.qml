import QtQuick 1.1
import Components.SoundDiffusion 1.0


SystemPage {
    id: sounddiffusion
    source: "images/sound_diffusion.jpg"
    text: qsTr("sound system")
    rootColumn: soundDiffusionSystem

    Component {
        id: soundDiffusionSystem
        SoundDiffusionSystem {}
    }
}

