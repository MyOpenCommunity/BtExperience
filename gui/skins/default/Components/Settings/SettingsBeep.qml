import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    ControlSwitch {
        text: pageObject.names.get('BEEP', global.guiSettings.beep)
        onPressed: global.guiSettings.beep = !global.guiSettings.beep
        status: !global.guiSettings.beep
    }
}
