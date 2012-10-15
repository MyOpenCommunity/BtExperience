import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column

    signal textLanguageChanged(int config)

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: textLanguageChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
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
