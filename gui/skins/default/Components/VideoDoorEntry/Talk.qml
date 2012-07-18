import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: column

    property alias where: controlCall.where

    ControlCall {
        id: controlCall
        dataObject: dataModel
    }
}
