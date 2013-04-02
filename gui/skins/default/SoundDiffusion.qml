import QtQuick 1.1
import Components.SoundDiffusion 1.0
import BtObjects 1.0


/**
  \ingroup SoundDiffusion

  \brief The SoundDiffusion system page.
  */
SystemPage {
    id: sounddiffusion

    source: "images/background/sound_diffusion.jpg"
    text: qsTr("Sound System")
    rootColumn: monoChannelAmbient.count > 0 ? monoChannel : multiChannel
    rootData: monoChannelAmbient.count > 0 ? monoChannelAmbient.getObject(0) : null

    ObjectModel {
        id: monoChannelAmbient
        filters: [{objectId: ObjectInterface.IdMonoChannelSoundAmbient}]
    }

    Component {
        id: multiChannel
        SoundDiffusionSystem {}
    }

    Component {
        id: monoChannel
        SoundAmbient {}
    }
}
