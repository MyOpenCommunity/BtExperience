import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300
        Component.onCompleted: controlCall.state = "Ring1"
        ControlCall {
            id: controlCall
            leftImage: ""
            onMinusClicked: console.log("minusClicked")
            onPlusClicked: console.log("plusClicked")
            onControlClicked: console.log("controlClicked")
            onLeftButtonClicked: console.log("leftButtonClicked")
            onRightButtonClicked: console.log("rightButtonClicked")
            onButtonDownClicked: console.log("buttonDownClicked")
        }
    }
}
