import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/datetime.js" as DateTime

MenuColumn {
    id: column

    width: img.width
    height: img.height

    SvgImage {
        id: img

        source: "../../images/common/alarm-log_panel.svg"

        Item {
            id: realHeader
            width: parent.width
            height: 28
            anchors.top: parent.top

            Row {
                width: parent.width
                height: 14
                anchors.top: parent.top
                anchors.topMargin: 7

                Item {
                    height: parent.height
                    width: 11
                }

                Item {
                    height: parent.height
                    width: 5
                }

                Text {
                    height: parent.height
                    width: 147
                    text: qsTr("type")
                    color: "#4F4F4F"
                    font.pointSize: 10
                }

                Item {
                    height: parent.height
                    width: 5
                }

                Text {
                    height: parent.height
                    width: 111
                    text: qsTr("zone")
                    color: "#4F4F4F"
                    font.pointSize: 10
                }

                Item {
                    height: parent.height
                    width: 5
                }

                Text {
                    height: parent.height
                    width: 106
                    text: qsTr("date and time")
                    color: "#4F4F4F"
                    font.pointSize: 10
                }
            }
        }

        PaginatorList {
            id: paginator
            anchors {
                top: realHeader.bottom
                topMargin: parent.height / 100 * 2
            }
            spacing: parent.height / 100 * 1
            leftMargin: parent.width / 100 * 2.5
            buttonVisible: modelList.count !== 0
            elementsOnPage: privateProps.elementsOnPage
            source: ""

            onButtonClicked: modelList.clear()

            delegate: SvgImage {
                id: itemBackground

                property variant itemObject: modelList.getObject(index)

                source: "../../images/" + (index % 2 === 0 ? "common/row_background_01.svg" : "common/row_background_02.svg")
                anchors.horizontalCenter: parent === null ? undefined : parent.horizontalCenter

                Row {
                    anchors.fill: itemBackground

                    Row {
                        anchors.top: parent.top
                        anchors.topMargin: parent.height / 100 * 11

                        Item {
                            height: parent.height / 100 * 89
                            width: 5
                        }

                        Text {
                            height: parent.height / 100 * 89
                            width: 147
                            color: "white"
                            text: itemObject !== undefined ? pageObject.names.get('ALARM_TYPE', itemObject.type) : ""
                            font.pointSize: 10
                        }

                        Item {
                            height: parent.height / 100 * 89
                            width: 5
                        }

                        Text {
                            height: parent.height / 100 * 89
                            width: 111
                            color: "white"
                            text: itemObject !== undefined ? itemObject.number + "\n" + itemObject.name : ""
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                        }

                        Item {
                            height: parent.height / 100 * 89
                            width: 5
                        }

                        Text {
                            height: parent.height / 100 * 89
                            width: 106
                            color: "white"
                            text: itemObject !== undefined ? DateTime.format(itemObject.date_time)["date"] + "\n" + DateTime.format(itemObject.date_time)["time"] : ""
                            font.pointSize: 10
                        }

                        Item {
                            height: parent.height / 100 * 89
                            width: 7
                        }

                        SvgImage {
                            source: "../../images/common/icon_delete.svg"
                            MouseArea {
                                id: btnArea
                                anchors.fill: parent
                                onClicked: modelList.remove(index)
                            }
                        }
                    }
                }
            }

            model: modelList
        }

        Text {
            id: noAlarmText
            z: 1
            anchors.centerIn: parent
            text: qsTr("No Alarm Present")
            font.pointSize: 18
            visible: modelList.count === 0
        }
    }

    ObjectModel {
        id: modelList
        source: column.dataModel
        range: paginator.computePageRange(paginator.currentPage, privateProps.elementsOnPage)
    }

    QtObject {
        id: privateProps
        property int elementsOnPage: 8
    }
}
