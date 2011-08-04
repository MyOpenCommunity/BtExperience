import QtQuick 1.0
import "Stack.js" as Stack

Rectangle {
	id: toolbar
	property bool home: false
	height: 50
	gradient: Gradient {
	 GradientStop {
		 position: 0
		 color: "#ffffff"
	 }

	 GradientStop {
		 position: 0.6
		 color: "#c9c9c7"
	 }
	 GradientStop {
		 position: 1
		 color: "#757573"
	 }
 }
	anchors.right: parent.right
	anchors.rightMargin: 0
	anchors.left: parent.left
	anchors.leftMargin: 0
	anchors.top: parent.top
	anchors.topMargin: 0
	visible: true
	opacity: 0.6

	Image {
		id: homebutton
		x: 15
		y: 18
		source: "home.png"
		visible: home
		MouseArea {
			anchors.fill: parent
			onClicked: Stack.backToHome()
		}
	}

 Text {
	 id: temperature
	 x: 51
	 y: 18
	 text: "19°C"
  font.bold: true
	 font.pixelSize: 12
 }

 Text {
	 id: date
	 x: 110
	 y: 18
	 text: Qt.formatDate(new Date, "dd/MM/yyyy")
	 font.bold: true
	 font.pixelSize: 12
 }

 Text {
	 id: time
	 x: 214
	 y: 18
	 text: Qt.formatTime(new Date, "hh:mm")
	 font.bold: true
	 font.pixelSize: 12
	 Timer {
		 interval: 500; running: true; repeat: true
		 onTriggered: time.text = Qt.formatTime(new Date, "hh:mm")
	 }
 }


}
