/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
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

                UbuntuLightText {
                    height: parent.height
                    width: 147
                    text: qsTr("type")
                    color: "#343434"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                Item {
                    height: parent.height
                    width: 5
                }

                UbuntuLightText {
                    height: parent.height
                    width: 111
                    text: qsTr("zone")
                    color: "#343434"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                Item {
                    height: parent.height
                    width: 5
                }

                UbuntuLightText {
                    height: parent.height
                    width: 106
                    text: qsTr("date and time")
                    color: "#343434"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }
            }
        }

        PaginatorOnBackground {
            id: paginator
            anchors {
                top: realHeader.bottom
                topMargin: parent.height / 100 * 1.5
                left: parent.left
                leftMargin: parent.width / 100 * 2.5
                right: parent.right
                bottom: parent.bottom
            }
            spacing: parent.height / 100 * 2
            elementsOnPage: privateProps.elementsOnPage

            delegate: SvgImage {
                id: itemBackground

                property variant itemObject: modelList.getObject(index)

                source: "../../images/" + (index % 2 === 0 ? "common/row_background_01.svg" : "common/row_background_02.svg")

                Item {
                    id: spacer1
                    height: 1
                    width: 5
                    anchors.left: parent.left
                }

                UbuntuLightText {
                    id: alarmTypeText
                    height: parent.height / 100 * 89
                    width: 147
                    color: "white"
                    text: itemObject !== undefined ? pageObject.names.get('ALARM_TYPE', itemObject.type) : ""
                    elide: Text.ElideRight
                    font.pixelSize: 16
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 11
                        left: spacer1.right
                    }
                }

                Item {
                    id: spacer2
                    height: 1
                    width: 5
                    anchors.left: alarmTypeText.right
                }

                UbuntuLightText {
                    id: alarmNameText
                    height: parent.height / 100 * 89
                    width: 111
                    color: "white"
                    text: itemObject !== undefined ? itemObject.number + "\n" + itemObject.name : ""
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    font.pixelSize: 16
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 11
                        left: spacer2.right
                    }
                }

                Item {
                    id: spacer3
                    height: 1
                    width: 5
                    anchors.left: alarmNameText.right
                }

                UbuntuLightText {
                    id: alarmDateTimeText
                    height: parent.height / 100 * 89
                    width: 106
                    color: "white"
                    text: itemObject !== undefined ? DateTime.format(itemObject.date_time)["date"] + "\n" + DateTime.format(itemObject.date_time)["time"] : ""
                    font.pixelSize: 13
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 11
                        left: spacer3.right
                    }
                }

                Item {
                    id: spacer4
                    height: 1
                    width: 7
                    anchors.left: alarmDateTimeText.right
                }

                SvgImage {
                    source: "../../images/common/icon_delete.svg"
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 11
                        left: spacer4.right
                    }
                }

                BeepingMouseArea {
                    id: btnArea
                    anchors {
                        fill: parent
                        leftMargin: parent.width / 8 * 7
                    }
                    onPressed: modelList.remove(index)
                }
            }

            buttonComponent: ButtonThreeStates {
                id: button
                defaultImage: "../../images/common/button_delete_all.svg"
                pressedImage: "../../images/common/button_delete_all_press.svg"
                shadowImage: "../../images/common/shadow_button_delete_all.svg"
                visible: modelList.count !== 0
                text: qsTr("remove all")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 12
                onPressed: modelList.clear()
            }

            model: modelList
        }

        UbuntuLightText {
            id: noAlarmText
            z: 1
            anchors.centerIn: parent
            width: parent.width - parent.width / 100 * 10
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No Alarm Present")
            font.pixelSize: 24
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
