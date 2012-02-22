// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    id: alarmAlert
    width: 300
    height: 150

    signal ignoreClicked
    signal alarmLogClicked

    Column {
        id: column1
        anchors.fill: parent

        Column {
            id: column2
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 10

            Text {
                font.bold: true
                font.pointSize: 12
                text: qsTr("Allarme!")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "20:15 - 21/01/2012"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Intrusione: zona 6 - cucina"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Row {
            id: row1
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: column2.bottom
            anchors.bottom: parent.bottom

            Rectangle {
                id: rectangle1
                width: parent.width / 2; height: 30
                color: "lightgreen"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Text {
                    wrapMode: Text.WordWrap
                    text: qsTr("Registro allarmi")
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: alarmAlert.alarmLogClicked()
                }
            }

            Rectangle {
                width: parent.width / 2; height: 30
                color: "lightgreen"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Text {
                    anchors.fill: parent
                    text: qsTr("Ignora")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: alarmAlert.ignoreClicked()
                }
            }
        }
    }
}
