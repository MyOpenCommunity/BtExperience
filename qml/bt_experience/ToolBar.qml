import QtQuick 1.0

Rectangle {
	id: toolbar

	property string customButton: "toolbar/ico_home.png"
	signal customClicked

	width: 800 // useful for the Qt Quick designer
	height: 49
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
			id: custombutton
			y: 11
			x: 20
			source: customButton
			MouseArea {
				anchors.fill: parent
				onClicked: toolbar.customClicked()
			}
		}

		Text {
			id: temperature
			y: 16
			x: 60
			text: "19°C"
			font.bold: true
			font.pixelSize: 12
		}

		Text {
			id: date
			y: 16
			x: 120
			text: Qt.formatDate(new Date, "dd/MM/yyyy")
			font.bold: true
			font.pixelSize: 12
		}

		Text {
			id: time
			y: 16
			x: 220
			text: Qt.formatTime(new Date, "hh:mm")
			font.bold: true
			font.pixelSize: 12
			Timer {
				interval: 500; running: true; repeat: true
				onTriggered: time.text = Qt.formatTime(new Date, "hh:mm")
			}
		}

  Image {
	  id: image1
	  x: 560
	  y: 11
	  source: "toolbar/ico_ora.png"
  }

  Image {
	  id: image2
	  x: 600
	  y: 11
	  source: "toolbar/ico_allarme.png"
  }

  Image {
	  id: image3
	  x: 641
	  y: 11
	  source: "toolbar/ico_antifurtoIns.png"
  }

  Image {
	  id: image4
	  x: 696
	  y: 14
	  source: "toolbar/logo.png"
  }

}
