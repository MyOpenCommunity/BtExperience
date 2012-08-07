import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: Math.max(1, screenSaverTypesView.model.count * 50)
    signal screenSaverTypesChanged(int type)

    ListView {
        id: screenSaverTypesView
        anchors.fill: parent
        interactive: false
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: screenSaverTypesChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [
                            GuiSettings.None,
                            GuiSettings.DateTime,
                            GuiSettings.Text,
                            GuiSettings.Image,
                            GuiSettings.Rectangles,
                            GuiSettings.Slideshow
                        ]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('SCREEN_SAVER_TYPE', l[i])
                           })
            }
        }
    }
}
