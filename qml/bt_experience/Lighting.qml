import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: systems
	source: "systems/illuminazione.jpg"

	ToolBar {
		id: toolbar
		onCustomClicked: Stack.backToHome()
	}

 Text {
	 id: text1
	 x: -114
	 y: 222
	 color: "#ffffff"
	 text: "illuminazione"
	 rotation: 270
	 font.pixelSize: 50
 }
}
