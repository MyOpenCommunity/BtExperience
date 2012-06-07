import QtQuick 1.1
import Components 1.0


MenuColumn {
    width: column.width
    height: column.height

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
