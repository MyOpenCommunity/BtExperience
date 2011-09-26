import QtQuick 1.1

Rectangle {
        id: button
        color: "#394d58"
        opacity: 0.8
        property string text: ""
        property string icon: ""
        property int x_origin: x + width
        property int y_origin: y + height
        signal clicked

  Text {
        x: 50
        y: 40
        color: "#ffffff"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 9
        anchors.right: parent.right
        anchors.rightMargin: 14
        text: parent.text

        verticalAlignment: Text.AlignTop
        font.bold: true
        font.pixelSize: 16
  }
  smooth: true
  transform: Rotation { origin.x: button.x_origin ; origin.y: button.y_origin; axis { x: 0; y: 1; z: 0 } angle: -25 }

  MouseArea {
          anchors.fill: parent
          onPressed: parent.color = "#475f69"
          onReleased: parent.color = "#394d58"
          onClicked: button.clicked()
  }

  Image {
          id: image1
          x: 5
          y: 5
          source: parent.icon
  }
}
