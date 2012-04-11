import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: 100
    signal basicSplitChanged(bool config)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: basicSplitChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [true,
                         false,
                        ]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('BASIC_SPLIT', l[i])
                           })
                if (dataModel.enable)
                    view.currentIndex = 0
                else
                    view.currentIndex = 1
            }
        }
    }
}
