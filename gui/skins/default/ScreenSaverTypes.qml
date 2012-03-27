import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 200
    signal screenSaverTypesChanged(string type)

    ListView {
        id: screenSaverTypesView
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: screenSaverTypesChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                for (var i = 0; i < 4; i++)
                    append({
                               "type": pageObject.names.get('SCREEN_SAVER_TYPE', i),
                               "name": pageObject.names.get('SCREEN_SAVER_TYPE', i)
                           })
            }
        }
    }
}
