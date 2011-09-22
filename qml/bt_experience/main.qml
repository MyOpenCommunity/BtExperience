import QtQuick 1.1
import "Stack.js" as Stack


Page {
    id: container

    Component.onCompleted: {
        Stack.container = container
        Stack.openPage("ThermalRegulation.qml")
    }
}
