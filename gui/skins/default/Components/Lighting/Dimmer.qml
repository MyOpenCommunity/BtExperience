import QtQuick 1.1
import Components 1.0

MenuColumn {
    width: 212
    height: column.height

    Column {
        id: column
        width: parent.width
        ButtonOnOff {
            id: onOff
            width: parent.width
            status: dataModel.active
            onClicked: dataModel.active = newStatus
        }

        ControlSlider {
            width: 212
            description: qsTr("light intensity")
            percentage: 20

            // TODO: maybe we need an indication of percentage as a text also
            // between the title and the slider bar
            // Something like:
            // text: dataModel.percentage + "%"
        }

        ControlTiming {
            id: timing
            width: 212
        }
    }
}
