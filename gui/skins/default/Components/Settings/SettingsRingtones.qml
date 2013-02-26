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
                if (volumePercentage > 0)
                    volumePercentage += 5
            }
            onMinusClicked: {
                if (volumePercentage < 100)
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
                onClicked: column.loadColumn(settingsRingtone, name, undefined, {type: itemObject.name})
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
