import QtQuick 1.1

MenuElement {
    Column {
        MenuItem {
            name: qsTr("registro allarmi")
            hasChild: true
        }
        MenuItem {
            name: qsTr("sistema attivo")
            hasChild: true
        }
        MenuItem {
            name: qsTr("scenario")
            description: qsTr("giorno")
            hasChild: true
        }

        Image {
            source: "images/common/bg_zone.png"
            Text {
                id: zoneText
                text: qsTr("zone")
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                anchors.bottom: zoneView.top
            }

            GridView {
                id: zoneView
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                width: cellWidth * 2
                height: cellHeight * 4
                interactive: false
                cellWidth: 102
                cellHeight: 50

                delegate: Image {
                    source: "images/common/btn_zona.png"
                    Row {
                        anchors.top: parent.top
                        Image {
                            source: model.status ? "images/common/on.png" : "images/common/off.png"
                        }
                        Text {
                            text: model.number
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: model.name
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                model: zoneModel
            }

            ListModel {
                id: zoneModel
                ListElement {
                    number: 1
                    name: "ingresso"
                    status: true
                }

                ListElement {
                    number: 2
                    name: "taverna"
                    status: true
                }

                ListElement {
                    number: 3
                    name: "mansarda"
                    status: false
                }

                ListElement {
                    number: 4
                    name: "box/cantina"
                    status: true
                }

                ListElement {
                    number: 5
                    name: "soggiorno"
                    status: false
                }

                ListElement {
                    number: 6
                    name: "cucina"
                    status: false
                }

                ListElement {
                    number: 7
                    name: "camera"
                    status: false
                }

                ListElement {
                    number: 8
                    name: "cameretta"
                    status: false
                }

            }

        }

        Image {
            source: "images/common/btn_imposta_zone.png"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("imposta zone")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
            }
        }

    }
}
