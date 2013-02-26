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

    PaginatorList {
        id: paginator
        currentIndex: -1
        onCurrentPageChanged: column.closeChild()
        delegate: MenuItemDelegate {
            itemObject: objModel.getObject(index)
            name: global.ringtoneManager.descriptionFromType(itemObject.name)
            hasChild: true
            onClicked: column.loadColumn(settingsRingtone, name, undefined, {type: itemObject.name})
        }
        model: objModel
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
