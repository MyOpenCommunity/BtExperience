import QtQuick 1.1

BorderImage {
    id: item
    property alias menuColumn: conn.target

    source: "../images/common/ombra1elemento.png"
    border { left: 30; top: 30; right: 30; bottom: 30; }
    anchors { leftMargin: -25; topMargin: -25; rightMargin: -25; bottomMargin: -25 }
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch

    Connections {
        id: conn
        target: null
        onDestroyed: item.destroy()
    }
}

