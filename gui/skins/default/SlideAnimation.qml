import QtQuick 1.1

PageAnimation {
    function pushInStart() {
        animPushIn.start()
    }

    function popInStart() {
        animPopIn.start()
    }

    function pushOutStart() {
    }

    function popOutStart() {
    }

    SequentialAnimation {
        id: animPushIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "z"; value: 1 }
        NumberAnimation { target: page; property: "x"; from: 1024; to: 0; duration: transition_duration }

        PropertyAction { target: page; property: "z"; value: 0 }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animPopIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "z"; value: 1 }
        NumberAnimation { target: page; property: "x"; from: -1024; to: 0; duration: transition_duration }

        PropertyAction { target: page; property: "z"; value: 0 }
        ScriptAction {
            script: animationCompleted()
        }
    }
}
