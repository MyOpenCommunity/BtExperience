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


MenuColumn {
    id: column

    ObjectModel {
        // this must stay here otherwise theModel cannot be constructed properly
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    MediaModel {
        id: theModel
        source: objectModel.getObject(0).messages
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_messaggi_ricevuti.svg"
    }

    UbuntuLightText {
        id: caption

        font.pixelSize: 14

        text: theModel.count === 0 ? "" : theModel.count + (theModel.count === 1 ? qsTr(" message") : qsTr(" messages"))
        verticalAlignment: Text.AlignVCenter
        color: "#323232"
        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 2.65
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
        }
    }

    PaginatorOnBackground {
        id: paginator

        elementsOnPage: 9
        spacing: 5

        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 10.62
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.65
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }

        delegate: ColumnMessagesDelegate {
            itemObject: theModel.getObject(index)

            onDelegateClicked: {
                itemObject.isRead = true
                column.loadColumn(messageRead, itemObject.sender, itemObject)
            }
        }

        buttonComponent: ButtonThreeStates {
            id: button
            defaultImage: "../../images/common/button_delete_all.svg"
            pressedImage: "../../images/common/button_delete_all_press.svg"
            shadowImage: "../../images/common/shadow_button_delete_all.svg"
            visible: theModel.count !== 0
            text: qsTr("remove all")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 12
            onPressed: theModel.clear()
        }
        model: theModel
    }

    Component {
        id: messageRead
        MessageRead {}
    }
}
