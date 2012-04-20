import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 100
    signal keyboardLanguageChanged(int config)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: keyboardLanguageChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                // TODO use keyboard layout data
                var l = [
                            GuiSettings.Italian,
                            GuiSettings.English,
                        ]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('LANGUAGE', l[i])
                           })
            }
        }
    }
}
