import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/datetime.js" as DateTime

MenuColumn {
    id: column
    width: img.width;
    height: paginator.height
    property string imagesPath: "../../images/"

    Image {
        id: img
        width: 424
        height: 390
        source: imagesPath + "common/bg_registro_allarmi.png"

        PaginatorList {
            id: paginator
            width: parent.width
            listWidth: parent.width
            listHeight: parent.height
            buttonVisible: true
            elementsOnPage: privateProps.elementsOnPage

            header: listHeader

            onButtonClicked: modelList.clear()

            delegate: Image {
                id: itemBackground
                property variant itemObject: modelList.getObject(index)
                property bool active: column.animationRunning === false

                source: imagesPath + (index % 2 === 0 ? "common/bg_registro_riga1.png" : "common/bg_registro_riga2.png")
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
                            text: itemObject !== undefined ? itemObject.source.number + "\n" + itemObject.source.name : ""
                            wrapMode: Text.WordWrap
                            font.pointSize: 12
                        }

                        Text {
                            color: "white"
                            width: 105
                            text: itemObject !== undefined ? DateTime.format(itemObject.date_time)["date"] + "\n" + DateTime.format(itemObject.date_time)["time"] : ""
                            font.pointSize: 12
                        }
                    }

                    Image {
                        source: imagesPath + "common/btn_elimina.png"
                        MouseArea {
                            id: btnArea
                            anchors.fill: parent
                            onClicked: modelList.remove(index);
                        }
                    }
                }
            }

            footer: listFooter

            model: modelList
        }
    }

    Component {
        id: listHeader

        Row {
            width: paginator.width; height: 30

            Item {
                width: 10
                height: 5
            }

            Text {
                width: 125
                text: qsTr("type")
                color: "#4F4F4F"
                font.pointSize: 12
            }

            Text {
                width: 125
                text: qsTr("zone")
                color: "#4F4F4F"
                font.pointSize: 12
            }

            Text {
                width: 105
                text: qsTr("date and time")
                color: "#4F4F4F"
                font.pointSize: 12
            }
        }
    }

    Component {
        id: listFooter
        Row {
            visible: paginator.totalPages > 1
            Item {
                width: 10
                height: 5
            }
            Text {
                height: 60
                text: qsTr("page %1 of %2").arg(paginator.currentPage).arg(paginator.totalPages)
                color: "#4F4F4F"
            }
        }
    }

    FilterListModel {
        id: modelList
        source: column.dataModel
        range: paginator.computePageRange(paginator.currentPage, privateProps.elementsOnPage)
    }

    QtObject {
        id: privateProps
        property int elementsOnPage: 6
    }
}
