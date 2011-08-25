import QtQuick 1.0

Image {
    id: toolbar

    property string fontFamily
    property int fontSize: 15
    property string customButton: "toolbar/ico_home.png"
    signal customClicked

    source: "toolbar/barra.png"

    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    visible: true


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
        x: 69
        text: "19°C"
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
    }

    Text {
        id: date
        y: 16
        x: 124
        text: Qt.formatDate(new Date, "dd/MM/yyyy")
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
    }

    Text {
        id: time
        y: 16
        x: 221
        text: Qt.formatTime(new Date, "hh:mm")
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
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
