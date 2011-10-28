import QtQuick 1.1

Image {
    id: toolbar

    property string fontFamily
    property int fontSize: 15
    signal homeClicked
    signal exitClicked

    width: 1024
    height: 65
    source: "toolbar/toolbar.png"


    Image {
        id: homebutton
        y: 5
        x: 10
        source: "toolbar/ico_home.png"
        MouseArea {
            anchors.fill: parent
            onClicked: toolbar.homeClicked()
        }
    }

    Text {
        id: temperature
        y: 16
        x: 70
        text: "19°C"
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
    }

    Text {
        id: date
        y: 16
        x: 130
        text: Qt.formatDate(new Date, "dd/MM/yyyy")
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
    }

    Text {
        id: time
        y: 16
        x: 242
        text: Qt.formatTime(new Date, "hh:mm")
        font.pixelSize: toolbar.fontSize
        font.family: toolbar.fontFamily
        Timer {
            interval: 500; running: true; repeat: true
            onTriggered: time.text = Qt.formatTime(new Date, "hh:mm")
        }
    }

    Image {
          id: image4
          x: 473
          y: 16
          source: "toolbar/logo.png"
    }

    Image {
        id: image5
        x: 57
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image6
        x: 115
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image7
        x: 229
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image8
        x: 295
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image1
        x: 960
        y: 5
        source: "toolbar/ico_spegni.png"
        MouseArea {
            anchors.fill: parent
            onClicked: toolbar.exitClicked()
        }
    }

    Image {
        id: image2
        x: 942
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image3
        x: 896
        y: 5
        source: "toolbar/ico_sveglia.png"
    }

    Image {
        id: image9
        x: 887
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image10
        x: 841
        y: 5
        source: "toolbar/ico_antifurto.png"
    }

    Image {
        id: image11
        x: 831
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

    Image {
        id: image12
        x: 784
        y: 5
        source: "toolbar/ico_allarme.png"
    }

    Image {
        id: image13
        x: 772
        y: 1
        source: "toolbar/toolbar_separazione.png"
    }

}
