import QtQuick 1.1

PageAnimation {
    animationPushIn: animIn
    animationPushOut: animOut
    animationPopIn: animIn
    animationPopOut: animOut

    SequentialAnimation {
        id: animIn
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 0; to: 1; duration: transition_duration }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animOut
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 1; to: 0; duration: transition_duration }

        ScriptAction {
            script: animationCompleted()
        }
    }
}
