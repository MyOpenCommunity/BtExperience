import QtQuick 1.0
import "Stack.js" as Stack


Image {
	id: page
	width:  800
	height: 480

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
				ScriptAction { script: Stack.pushPageDone(); }
			}
		},
			Transition {
			from: 'offscreen_left'; to: ''
			SequentialAnimation {
				PropertyAnimation { properties: "x"; duration: 1000; easing.type: Easing.OutBack }
				ScriptAction { script: Stack.backToHomeDone(); }
			}
		}
	]
}

