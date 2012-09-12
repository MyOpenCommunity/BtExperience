import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: mainarea
    source: "images/home/home.jpg"
    property int floorUii

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: Stack.backToHome()
    }

    UbuntuLightText {
        id: pageTitle
        text: qsTr("Rooms")
        font.pixelSize: 50
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
    }

    ControlPathView {
        x0FiveElements: 180
        x0ThreeElements: 250
        y0: 155
        x1: 497
        y1: 105
        x2FiveElements: 784
        x2ThreeElements: 714

        ObjectModel {
            id: usersModel
            source: myHomeModels.rooms
        }
        model: usersModel
        anchors {
            right: parent.right
            rightMargin: 30
            left: parent.left
            leftMargin: 30
            top: pageTitle.bottom
            topMargin: 50
            bottom: floorView.top
        }
    }

    ListView {
        id: floorView
        orientation: ListView.Horizontal
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 100
        width: 140 * floorsModel.count
        delegate: Image {
            property variant itemObject: floorsModel.getObject(index)

            source: index === floorView.currentIndex ? "images/common/pianoS.png" : "images/common/piano.png"
            UbuntuLightText {
                text: itemObject.description
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: index === floorView.currentIndex === true ? "white" : "black"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: floorView.currentIndex = index
            }
        }

        onCurrentIndexChanged: {
            mainarea.floorUii = floorsModel.getObject(currentIndex).uii
        }

        MediaModel {
            source: myHomeModels.floors
            id: floorsModel
        }

        model: floorsModel
    }

}


