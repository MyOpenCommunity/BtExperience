import QtQuick 1.0

Image {
	id: mainarea
	width: 800
	height: 480
	source: "bg.png"

 Rectangle {
	 id: toolbar
	 height: 50
	 anchors.right: parent.right
	 anchors.rightMargin: 0
	 anchors.left: parent.left
	 anchors.leftMargin: 0
	 anchors.top: parent.top
	 anchors.topMargin: 0
	 visible: true
	 opacity: 0.6

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
	  text: "03/08/2011"
   font.bold: true
	  font.pixelSize: 12
  }

  Text {
	  id: text1
	  x: 214
	  y: 18
	  text: "17:53"
   font.bold: true
	  font.pixelSize: 12
  }
 }



 ListView {
	 ListModel {
		 id: favouritesModel

		 ListElement {
			 thumb: "fav1.png"
		 }
		 ListElement {
			 thumb: "fav2.png"
		 }
		 ListElement {
			 thumb: "fav3.png"
		 }
		 ListElement {
			 thumb: "fav4.png"
		 }
		 ListElement {
			 thumb: "fav5.png"
		 }
		 ListElement {
			 thumb: "fav6.png"
		 }
	 }

	 Component {
		 id: favouritesDelegate
		 Item {
			 width: 133
			 height: 100
			 Image {
				 id: favouritesImage
				 source: thumb
				 anchors.horizontalCenter: parent.horizontalCenter
				 anchors.verticalCenter: parent.verticalCenter
				 z:1
			 }
			 Rectangle {
				 id: shadow
				 gradient: Gradient {
					 GradientStop { position: 0.0; color: "#214045" }
					 GradientStop { position: 1.0; color: "#8ca8b4" }
				 }

				 opacity: 0.5
				 width: favouritesImage.width + 10
				 height: favouritesImage.height
				 x: favouritesImage.x
				 y: favouritesImage.y
				 transform: Translate { y: -5; x: -5 }
			 }
		 }
	 }

	 id: favourites
	 model: favouritesModel
	 delegate: favouritesDelegate
	 orientation: ListView.Horizontal
	 y: 380
	 height: 100
	 anchors.right: parent.right
	 anchors.rightMargin: 0
	 anchors.left: parent.left
	 anchors.leftMargin: 0
	 anchors.bottom: parent.bottom
	 anchors.bottomMargin: 0
 }

 PathView {
	 ListModel {
		 id: usersModel
		 ListElement {
			 image: "bimbi.jpg"
			 name: "bimbi"
		 }
		 ListElement {
			 image: "papa.jpg"
			 name: "papà"
		 }
		 ListElement {
			 image: "mamma.jpg"
			 name: "mamma"
		 }
		 ListElement {
			 image: "famiglia.jpg"
			 name: "famiglia"
		 }
	 }

	 Component {
		 id: usersDelegate
		 Image {
			scale: PathView.iconScale
			 Rectangle {
				 id: userBox
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
				 anchors.bottomMargin: 30
				 text: name
				 font.bold: false
				 font.pixelSize: 16
			 }
			 source: image
			 smooth: true
			 width: 380
			 height: 210
			 transform: Rotation { origin.x: 30; origin.y: 30; axis { x: 0; y: 1; z: 0 } angle: 30 }
		 }

	 }

	 id: users
	 model: usersModel
	 delegate: usersDelegate
	 path:  Path {
	 	startX: 200; startY: 100
	 	PathAttribute { name: "iconScale"; value: 0.6 }
	 	PathLine { x: 450; y: 240 }
	 	PathAttribute { name: "iconScale"; value: 1.0 }
	 }


	 width: 480
	 anchors.bottom: favourites.top
	 anchors.bottomMargin: 0
	 anchors.top: toolbar.bottom
	 anchors.topMargin: 0
	 anchors.left: parent.left
	 anchors.leftMargin: 0
	 interactive: false
 }

 Item {
	 id: pages
  x: 480
  y: 50
	 anchors.right: parent.right
	 anchors.rightMargin: 0
	 anchors.left: users.right
	 anchors.leftMargin: 0
	 anchors.bottom: favourites.top
	 anchors.bottomMargin: 0
	 anchors.top: toolbar.bottom
	 anchors.topMargin: 0

  Column {
	  id: column1
	  anchors.top: parent.top
	  anchors.topMargin: 10
	  anchors.bottom: parent.bottom
	  anchors.bottomMargin: 10
	  anchors.right: parent.right
	  width: 150
	  spacing: 5

	  Rectangle {
		  id: multimedia
		  width: parent.width
		  height: 66
		color: "#394d58"
		opacity: 0.8
		Text {
	  color: "#ffffff"
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 10
			anchors.right: parent.right
			anchors.rightMargin: 20
			text: "multimedia"
   verticalAlignment: Text.AlignTop
			font.bold: true

		}
		smooth: true
		transform: Rotation { origin.x: multimedia.x + multimedia.width ; origin.y: multimedia.y + multimedia.height; axis { x: 0; y: 1; z: 0 } angle: -25 }
	  }

	  Rectangle {
		id: rooms
		width: parent.width
		height: 66
		color: "#394d58"
		opacity: 0.8
		Text {
	  color: "#ffffff"
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 10
			anchors.right: parent.right
			anchors.rightMargin: 20
			text: "stanze"
			font.bold: true
		}
		smooth: true
		transform: Rotation { origin.x: rooms.x + rooms.width ; origin.y: 0; axis { x: 0; y: 1; z: 0 } angle: -25 }
	  }

	  Rectangle {
		  id: systems
		  width: parent.width
		  height: 64
		  color: "#394d58"
		  opacity: 0.8
		Text {
	  color: "#ffffff"
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 10
			anchors.right: parent.right
			anchors.rightMargin: 20
			text: "sistemi"
			font.bold: true
		}
		smooth: true
		transform: Rotation { origin.x: systems.x + systems.width ; origin.y: 0; axis { x: 0; y: 1; z: 0 } angle: -25 }
	  }

	  Rectangle {
		  id: settings
		  width: parent.width
		  height: 68
		  color: "#394d58"
		  opacity: 0.8
		Text {
	  color: "#ffffff"
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 10
			anchors.right: parent.right
			anchors.rightMargin: 20
			text: "opzioni"
		font.bold: true
		}
		smooth: true
		transform: Rotation { origin.x: settings.x + settings.width ; origin.y: 0; axis { x: 0; y: 1; z: 0 } angle: -25 }
	  }
  }
 }
}


