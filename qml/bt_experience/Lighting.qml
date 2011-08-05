import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: systems
	source: "systems/illuminazione.jpg"

	ToolBar {
		id: toolbar
		onCustomClicked: Stack.backToHome()
	}
	 FontLoader { id: localFont; source: "MyriadPro-Light.otf" }

 Item {
	 x: 50
	 y: 400

	 Text {
		 id: text1
		 color: "#ffffff"
		 text: "illuminazione"
		 rotation: 270
		 font.pixelSize: 54
		 font.family: localFont.name
		 anchors.fill: parent
	 }
 }

}
