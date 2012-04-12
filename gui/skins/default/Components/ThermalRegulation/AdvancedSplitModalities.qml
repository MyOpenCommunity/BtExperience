import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: element
    width: 212
    height: 300

    signal modeChanged(int mode)

    ListView {
        id: view
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            onClicked: {
                modeChanged(model.type)
                element.closeElement()
            }
        }
        model: ListModel {
            id: modelList
            Component.onCompleted: {
                var l = [SplitProgram.ModeOff,
                         SplitProgram.ModeWinter,
                         SplitProgram.ModeSummer,
                         SplitProgram.ModeFan,
                         SplitProgram.ModeDehumidification,
                         SplitProgram.ModeAuto]
                for (var i = 0; i < l.length; i++)
                    append({
                               "type": l[i],
                               "name": pageObject.names.get('MODE', l[i])
                           })
            }
        }
    }
}
