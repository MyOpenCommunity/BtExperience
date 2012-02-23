// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    id: alarmAlert
    width: 300
    height: 150
    property string alarmDateTime: "20:15 - 21/01/2012"
    property string alarmLocation: "Intrusione: zona 6 - cucina"

    signal ignoreClicked
    signal alarmLogClicked


    Text {
        id: tagline
        font.bold: true
        font.pointSize: 12
        text: qsTr("Allarme!")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    Text {
        id: datetime
        text: alarmAlert.alarmDateTime
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: tagline.bottom
        anchors.topMargin: 15
    }


    Text {
        id: location
        text: alarmAlert.alarmLocation
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: datetime.bottom
        anchors.topMargin: 10
    }

    Row {
        id: row1
        width: parent.width
        anchors.bottom: parent.bottom

        Rectangle {
            id: rectangle1
            width: parent.width / 2; height: 30
            color: "lightgreen"

            Text {
                wrapMode: Text.WordWrap
                text: qsTr("Registro allarmi")
                anchors.fill: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("alarm log clicked");
                    alarmAlert.alarmLogClicked();
                }
            }
        }

        Rectangle {
            width: parent.width / 2; height: 30
            color: "lightgreen"

            Text {
                anchors.fill: parent
                text: qsTr("Ignora")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("ignore clicked");
                    alarmAlert.ignoreClicked();
                }
            }
        }
    }
}
