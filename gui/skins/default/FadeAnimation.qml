import QtQuick 1.1

PageAnimation {
    pushIn: animIn
    pushOut: animOut
    popIn: animIn
    popOut: animOut

    SequentialAnimation {
        id: animIn
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 0; to: 1; duration: transitionDuration }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animOut
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 1; to: 0; duration: transitionDuration }

        ScriptAction {
            script: animationCompleted()
        }
        PropertyAction { target: page; property: "opacity"; value: 1}
    }
}
