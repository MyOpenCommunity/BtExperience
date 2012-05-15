import QtQuick 1.1
import Components 1.0


Rectangle {
    id: bg

    property string source
    property string title

    color: "gray"
    height: 90
    radius: 4

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
