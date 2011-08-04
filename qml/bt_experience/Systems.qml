import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: systems
	source: "bg2.jpg"

	ToolBar {
		id: toolbar
		onCustomClicked: Stack.backToHome()
	}
}
