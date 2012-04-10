import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
    width: 212
    height: 300

    signal modalityChanged(int modality)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: modalityChanged(model.type)
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [SplitAdvancedScenario.ModeOff,
                         SplitAdvancedScenario.ModeWinter,
                         SplitAdvancedScenario.ModeSummer,
                         SplitAdvancedScenario.ModeFan,
                         SplitAdvancedScenario.ModeDehumidification,
                         SplitAdvancedScenario.ModeAuto]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('MODE', l[i])
                           })
            }
        }
    }
}
