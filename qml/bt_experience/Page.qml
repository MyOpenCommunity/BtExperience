import QtQuick 1.0
import "Stack.js" as Stack


Image {
    id: page
    width:  800
    height: 480

    property  alias lightFont: lightFont
    property  alias regularFont: regularFont
    property  alias semiBoldFont: semiBoldFont

    FontLoader { id: lightFont; source: "MyriadPro-Light.otf" }
    FontLoader { id: regularFont; source: "MyriadPro-Regular.otf" }
    FontLoader { id: semiBoldFont; source: "MyriadPro-Semibold.otf" }

    states: [
        State {
            name: "offscreen_right"
            PropertyChanges {
                target: page
                x: 800
            }
        },
        State {
            name: "offscreen_left"
            PropertyChanges {
                target: page
                x: -800
            }
        }
    ]
    transitions: [
        Transition {
            from: 'offscreen_right'; to: ''
            SequentialAnimation {
                PropertyAnimation { properties: "x"; duration: 1000; easing.type: Easing.OutBack }
                ScriptAction { script: Stack.changePageDone(); }
            }
        },
            Transition {
            from: 'offscreen_left'; to: ''
            SequentialAnimation {
                PropertyAnimation { properties: "x"; duration: 1000; easing.type: Easing.OutBack }
                ScriptAction { script: Stack.changePageDone(); }
            }
        }
    ]
}

