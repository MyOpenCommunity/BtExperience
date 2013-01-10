import QtQuick 1.1

PageAnimation {
    pushIn: animPushIn
    pushOut: animPushOut
    popIn: animPopIn
    popOut: animPopOut

    SequentialAnimation {
        id: animPushIn
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 0; to: 1; duration: transitionDuration }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animPushOut
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "opacity"; value: 1 }
    }

    SequentialAnimation {
        id: animPopIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "opacity"; value: 1 }
    }

    SequentialAnimation {
        id: animPopOut
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 1; to: 0; duration: transitionDuration }
        ScriptAction {
            script: animationCompleted()
        }
    }
}
