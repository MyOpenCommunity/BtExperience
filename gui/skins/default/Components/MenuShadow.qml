import QtQuick 1.1


/**
  \ingroup Core

  \brief A shadow sorrounding a menu.
  */
BorderImage {
    id: item

    /** type:Object the MenuColumn this shadow refers to */
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

