import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column

    signal skinChanged(int config)

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: skinChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var s = [
                            GuiSettings.Clear,
                            GuiSettings.Dark,
                        ]
                for (var i = 0; i < s.length; i++)
                    append({
                               "type": s[i],
                               "name": pageObject.names.get('SKIN', s[i])
                           })
            }
        }
    }
}
