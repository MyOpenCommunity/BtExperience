/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
    text: systemNames.get(Container.IdSoundDiffusionMulti)
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
