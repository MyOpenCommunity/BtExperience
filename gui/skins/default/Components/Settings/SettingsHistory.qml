import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column


    ControlSwitch {
        text: pageObject.names.get('BROWSER_HISTORY', global.keepingHistory)
        onPressed: global.keepingHistory = !global.keepingHistory
        status: !global.keepingHistory
    }
}
