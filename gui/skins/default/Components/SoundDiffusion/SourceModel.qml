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
import BtObjects 1.0
import Components 1.0

Item {
    property alias model: sourceModel

    SystemsModel { id: multiModel; systemId: Container.IdSoundDiffusionMulti }
    SystemsModel { id: monoModel; systemId: Container.IdSoundDiffusionMono }

    SystemsModel { id: ipradioContainer; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }
    MediaModel {
        id: ipradioModel
        containers: [ipradioContainer.systemUii]
        source: myHomeModels.mediaLinks
    }

    ObjectModel {
        id: sourceModel
        containers: [multiModel.systemUii, monoModel.systemUii]
        filters: ipradioModel.count === 0 ? [{objectId: ObjectInterface.IdSoundSource}]:
                                            [{objectId: ObjectInterface.IdSoundSource}, {objectId: ObjectInterface.IdIpRadioSource}]
    }
}
