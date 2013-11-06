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
import BtExperience 1.0
import Components 1.0


MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    ObjectModelSource {
        id: sourceModel
    }

    ObjectModel {
        id: objModel
        source: sourceModel.model
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        ControlSlider {
            property int volumePercentage: global.audioState.getVolume(AudioState.RingtoneVolume)
            description: qsTr("Ringtone volume")
            percentage: volumePercentage
            onVolumePercentageChanged: global.audioState.setVolume(AudioState.RingtoneVolume, volumePercentage)
            onPlusClicked: {
                if (volumePercentage >= 0 && volumePercentage < 100)
                    volumePercentage += 5
            }
            onMinusClicked: {
                if (volumePercentage > 0 && volumePercentage <= 100)
                    volumePercentage -= 5
            }
            onSliderClicked: volumePercentage = Math.round(desiredPercentage / 5) * 5
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            elementsOnPage: 6
            onCurrentPageChanged: column.closeChild()
            delegate: MenuItemDelegate {
                itemObject: objModel.getObject(index)
                name: global.ringtoneManager.descriptionFromType(itemObject.name)
                hasChild: true
                onDelegateTouched: column.loadColumn(settingsRingtone, name, undefined, {type: itemObject.name})
            }
            model: objModel
        }
    }

    Component {
        id: settingsRingtone
        SettingsRingtone {}
    }

    Component.onCompleted: sourceModel.init([RingtoneManager.Alarm,
                                             RingtoneManager.Message,
                                             RingtoneManager.CCTVExternalPlace1,
                                             RingtoneManager.CCTVExternalPlace2,
                                             RingtoneManager.CCTVExternalPlace3,
                                             RingtoneManager.CCTVExternalPlace4,
                                             RingtoneManager.InternalIntercom,
                                             RingtoneManager.ExternalIntercom,
                                             RingtoneManager.IntercomFloorcall
                                            ])
}
