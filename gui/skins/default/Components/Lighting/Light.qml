import QtQuick 1.1
import Components 1.0


MenuColumn {
    Column {
        id: column

        ControlOnOff {
            active: dataModel.active
            onClicked: (timing.isEnabled && newStatus === true) ? dataModel.setActiveWithTiming() : dataModel.active = newStatus
        }

        ControlTiming {
            itemObject: dataModel
        }
    }
}
