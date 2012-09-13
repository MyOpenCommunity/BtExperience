import QtQuick 1.1
import Components.Text 1.0


Image {
    id: alarmAlert
    source: "../images/home/alert.png"
    width: 300
    height: 150
    property string alarmDateTime: "20:15 - 21/01/2012"
    property string alarmLocation: "Intrusione: zona 6 - cucina"

    signal ignoreClicked
    signal alarmLogClicked

    UbuntuMediumText {
        id: tagline
        font.pixelSize: 18
        text: qsTr("alarm!")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    UbuntuLightText {
        id: datetime
        text: alarmAlert.alarmDateTime
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: tagline.bottom
        anchors.topMargin: 15
    }


    UbuntuLightText {
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

        Image {
            source: "../images/common/btn_OKAnnulla.png"
            width: parent.width / 2; height: 30

            UbuntuLightText {
                wrapMode: Text.WordWrap
                text: qsTr("alarm log")
                anchors.centerIn: parent
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: {
                    alarmAlert.alarmLogClicked();
                }
            }
        }

        Image {
            source: "../images/common/btn_OKAnnulla.png"
            width: parent.width / 2; height: 30

            UbuntuLightText {
                anchors.centerIn: parent
                text: qsTr("ignore")
            }

            BeepingMouseArea {
                anchors.fill: parent
                onClicked: {
                    alarmAlert.ignoreClicked();
                }
            }
        }
    }
}
