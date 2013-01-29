import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    ControlTemperature {
        text: (dataModel.temperature / 10).toFixed(1) + "°C"
    }
}
