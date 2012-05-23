import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    property alias where: controlCall.where

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300
        ControlCall {
            id: controlCall
            dataObject: dataModel
        }
    }
}
