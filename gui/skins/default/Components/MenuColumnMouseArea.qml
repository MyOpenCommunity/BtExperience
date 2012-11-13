import QtQuick 1.1

MouseArea {
    id: item
    property alias menuColumn: conn.target

    Connections {
        id: conn
        target: null
        onDestroyed: item.destroy()
    }
}
