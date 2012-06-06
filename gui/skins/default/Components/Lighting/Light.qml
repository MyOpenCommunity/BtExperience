import QtQuick 1.1
import Components 1.0


MenuColumn {
    width: 212
    height: column.height

    Column {
        id: column

        width: parent.width

        ControlOnOff {
            id: onOff
            width: parent.width
            active: dataModel.active
            onClicked: timing.isEnabled ? dataModel.setActiveWithTiming() : dataModel.active = newStatus
        }

        ControlTiming {
            id: timing
            width: parent.width
            itemObject: dataModel
        }
    }
}
