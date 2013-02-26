import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0


MenuColumn {
    id: column

    // using a ListView, so I have to hardcode dim
    height: 450
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListModel {
        id: modelList

        Component.onCompleted: {
            var types = [
                        RingtoneManager.Alarm,
                        RingtoneManager.Message,
                        RingtoneManager.CCTVExternalPlace1,
                        RingtoneManager.CCTVExternalPlace2,
                        RingtoneManager.CCTVExternalPlace3,
                        RingtoneManager.CCTVExternalPlace4,
                        RingtoneManager.InternalIntercom,
                        RingtoneManager.ExternalIntercom,
                        RingtoneManager.IntercomFloorcall
                    ]
            var r = global.ringtoneManager
            for (var i = 0; i < types.length; ++i) {
                modelList.append(
                            {
                                name: r.descriptionFromType(types[i]),
                                type: types[i]
                            })
            }
        }
    }

    ListView {
        id: itemList

        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onClicked: column.loadColumn(settingsRingtone, model.name, undefined, {type: model.type})
        }

        model: modelList
    }

    Component {
        id: settingsRingtone
        SettingsRingtone {}
    }
}
