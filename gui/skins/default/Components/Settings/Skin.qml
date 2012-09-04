import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: 100
    signal skinChanged(int config)

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
