import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    ControlSwitch {
        text: pageObject.names.get('HELP_ICON', global.guiSettings.helpIcon)
        onPressed: global.guiSettings.helpIcon = !global.guiSettings.helpIcon
        status: !global.guiSettings.helpIcon
    }
}
