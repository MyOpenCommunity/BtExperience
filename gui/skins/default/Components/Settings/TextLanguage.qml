import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column

    signal textLanguageChanged(string config)

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        delegate: MenuItem {
            name: pageObject.names.get('LANGUAGE', modelData)
            isSelected: global.guiSettings.language === model.type
            onClicked: textLanguageChanged(model.type)
        }
        model: global.guiSettings.languages
    }
}
