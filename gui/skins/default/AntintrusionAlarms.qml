import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: img.width;
    height: img.height + paginator.height

    Image {
        id: img
        source: "images/common/bg_registro_allarmi.png"

        ListView {
            id: itemList

            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.bottomMargin: 5
            anchors.topMargin: 10
            anchors.fill: parent

            interactive: false

            header: Row {
                width: itemList.width; height: 30

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
                            text: itemObject !== undefined ? pageObject.names.get('ALARM_TYPE', itemObject.type) : ""
                            font.pointSize: 12
                        }

                        Text {
                            width: 125
                            color: "white"
                            text: itemObject !== undefined ? itemObject.zone.objectId + "\n" + itemObject.zone.name : ""
                            wrapMode: Text.WordWrap
                            font.pointSize: 12
                        }

                        Text {
                            color: "white"
                            width: 105
                            text: itemObject !== undefined ? Qt.formatDateTime(itemObject.date_time, "dd/MM/yyyy\nhh:mm") : ""
                            font.pointSize: 12
                        }
                    }

                    Image {
                        source: "images/common/btn_elimina.png"
                        MouseArea {
                            id: btnArea
                            anchors.fill: parent
                            onClicked: modelList.remove(index);
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
                    text: qsTr("Page " + paginator.currentPage + " of " + paginator.totalPages)
                    color: "#4F4F4F"
                }
            }

            model: modelList
        }
    }

    ObjectModel {
        id: modelList
        source: element.dataModel
        range: paginator.computePageRange(paginator.currentPage, privateProps.elementsOnPage)
    }

    QtObject {
        id: privateProps
        property int elementsOnPage: 5
    }

    Row {
        anchors.top: img.bottom
        Paginator {
            id: paginator
            totalPages: paginator.computePagesFromModelSize(modelList.size, privateProps.elementsOnPage)
        }

        Image {
            source: "images/common/btn_OKAnnulla.png"
            height: 35
            width: img.width - paginator.width * paginator.visible

            Text {
                text: qsTr("Remove all")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 12
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: console.log("Delete all alarms")
            }
        }
    }
}
