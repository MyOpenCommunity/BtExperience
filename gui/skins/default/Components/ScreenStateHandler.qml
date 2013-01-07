import QtQuick 1.1
import BtObjects 1.0

QtObject {
    id: forceScreenOn
    property bool enabled: false
    onEnabledChanged: {
        if (enabled)
            global.screenState.enableState(ScreenState.ForcedNormal)
        else
            global.screenState.disableState(ScreenState.ForcedNormal)
    }

    Component.onDestruction: global.screenState.disableState(ScreenState.ForcedNormal)
}
