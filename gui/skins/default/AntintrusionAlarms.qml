import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: img.width; height: img.height

    Image {
        id: img
        source: "images/common/bg_registro_allarmi.png"
    }

    ListView {
        id: itemList
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        anchors.fill: parent
        interactive: false

        header: Row {
            width: parent.width; height: 40
            Text {
                width: 125
                text: qsTr("TIPO")
            }

            Text {
                width: 125
                text: qsTr("ZONA")
            }

            Text {
                width: 105
                text: qsTr("DATA E ORA")
            }
        }

        function typeToText(type) {
            if (type === AntintrusionAlarm.ANTIPANIC_ALARM)
                return qsTr("anti-panico");
            else if (type === AntintrusionAlarm.INTRUSION_ALARM)
                return qsTr("intrusione");
            else if (type === AntintrusionAlarm.TAMPER_ALARM)
                return qsTr("manomissione");
            else if (type === AntintrusionAlarm.TECHNICAL_ALARM)
                return qsTr("tecnico");
        }

        delegate: Image {
            property variant itemObject: element.dataModel.getObject(index)
            property bool active: element.animationRunning === false

            source: index % 2 === 0 ? "images/common/bg_registro_riga1.png" : "images/common/bg_registro_riga2.png"
            Row {
                Text {
                    width: 125
                    color: "white"
                    text: itemList.typeToText(itemObject.type)
                }

                Text {
                    width: 125
                    color: "white"
                    text: itemObject.zone.objectId + "\n" + itemObject.zone.name
                    wrapMode: Text.WordWrap
                }

                Text {
                    color: "white"
                    width: 105
                    text: Qt.formatDateTime(itemObject.date_time, "dd/MM/yyyy\nhh:mm")
                }

                Image {
                    source: btnArea.pressed ? "images/common/btn_eliminaP.png" : "images/common/btn_elimina.png"
                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                    }
                }
            }
        }

        footer: Text {
            width: parent.width; height: 60
            text: qsTr("Pagina 1 di 4")
        }

        model: element.dataModel
    }
}
