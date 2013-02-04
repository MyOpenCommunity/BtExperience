import QtQuick 1.1
import Components 1.0


MenuColumn {
    ControlOn {
        onPressed: dataModel.activate()
        onReleased: dataModel.deactivate()
    }
}
