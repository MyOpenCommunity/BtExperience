import QtQuick 1.1
import Components 1.0


Image {
    id: bg
    height: 90

    property string source
    property string title

    Rectangle {
        anchors.fill: parent
        color: "gray"
        radius: 4
        opacity: 0.5
    }

    SvgImage {
        id: imgTitle
        source: bg.source
        width: height
        height: 0.8 * parent.height
        anchors {
            top: parent.top
            topMargin: 10
            bottom: parent.bottom
            bottomMargin: 10
            left: parent.left
            leftMargin: 10
        }
    }

    Rectangle {
        color: "transparent"
        height: 0.8 * parent.height
        anchors {
            top: parent.top
            topMargin: 5
            bottom: parent.bottom
            bottomMargin: 5
            left: imgTitle.right
            leftMargin: 10
        }

        EnergyDataTitle {
            title: bg.title
            anchors {
                fill: parent
                centerIn: parent
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
