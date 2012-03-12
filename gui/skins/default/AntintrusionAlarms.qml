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
        anchors.topMargin: 10
        anchors.fill: parent
        interactive: false

        header: Row {
            width: parent.width; height: 30

            Item {
                width: 10
                height: 5
            }

            Text {
                width: 125
                text: qsTr("TIPO")
                color: "#4F4F4F"
                font.pointSize: 12
            }

            Text {
                width: 125
                text: qsTr("ZONA")
                color: "#4F4F4F"
                font.pointSize: 12
            }

            Text {
                width: 105
                text: qsTr("DATA E ORA")
                color: "#4F4F4F"
                font.pointSize: 12
            }
        }

        delegate: Image {
            id: itemBackground
            property variant itemObject: modelList.getObject(index)
            property bool active: element.animationRunning === false

            source: index % 2 === 0 ? "images/common/bg_registro_riga1.png" : "images/common/bg_registro_riga2.png"
            Row {
                anchors.fill: itemBackground

                Row {
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    Item {
                        width: 10
                        height: 5
                    }

                    Text {
                        width: 125
                        color: "white"
                        text: pageObject.names.get('ALARM_TYPE', itemObject.type)
                        font.pointSize: 12
                    }

                    Text {
                        width: 125
                        color: "white"
                        text: itemObject.zone.objectId + "\n" + itemObject.zone.name
                        wrapMode: Text.WordWrap
                        font.pointSize: 12
                    }

                    Text {
                        color: "white"
                        width: 105
                        text: Qt.formatDateTime(itemObject.date_time, "dd/MM/yyyy\nhh:mm")
                        font.pointSize: 12
                    }
                }

                Image {
                    source: "images/common/btn_elimina.png"
                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        onClicked: element.dataModel.remove(index);
                    }
                }
            }
        }

        footer: Row {
            Item {
                width: 10
                height: 5
            }
            Text {
                height: 60
                text: qsTr("Pagina 1 di 4")
                color: "#4F4F4F"
            }
        }

        model: modelList
    }

    ObjectModel {
        id: modelList
        source: element.dataModel
    }
}
