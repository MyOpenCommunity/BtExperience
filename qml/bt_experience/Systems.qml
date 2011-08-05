import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: systems
	source: "bg2.jpg"

	ToolBar {
		id: toolbar
		onCustomClicked: Stack.backToHome()
	}

	PathView {
		ListModel {
			id: systemsModel
			ListElement {
				image: "systems/termoregolazione.jpg"
				name: "termoregolazione"
			}
			ListElement {
				image: "systems/illuminazione.jpg"
				name: "illuminazione"
			}

		}


		Component {
			id: systemsDelegate
			Image {
			   scale: PathView.iconScale
				Rectangle {
					id: systemBox
					width: 50
					anchors.left: parent.left
					anchors.leftMargin: -1
					anchors.top: parent.top
					anchors.topMargin: -1
					anchors.bottom: parent.bottom
					opacity: 0.4
					color: "#000000"
				}
				Text {
					opacity: 1
					color: "#ffffff"
					rotation: 270
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.bottomMargin: 80
					text: name
					font.bold: false
					font.pixelSize: 20
				}
				source: image
				smooth: true
				width: 450
				height: 300
				transform: Rotation { origin.x: 30; origin.y: 30; axis { x: 0; y: 1; z: 0 } angle: 30 }
			}

		}

		model: systemsModel
		delegate: systemsDelegate
		path:  Path {
		   startX: 200; startY: 100
		   PathAttribute { name: "iconScale"; value: 0.6 }
		   PathLine { x: 450; y: 240 }
		   PathAttribute { name: "iconScale"; value: 1.0 }
		}

		width: 480
		x: 100
		y: 100
		interactive: false
	}
}
