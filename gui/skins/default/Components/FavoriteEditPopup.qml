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
import Components.Text 1.0


/**
  * A popup to edit favorites.
  */
Column {
    id: popup

    property alias title: popupTitle.text
    property alias topInputLabel: titleText.text
    property alias topInputText: descriptionInput.text
    property alias bottomInputLabel: addressText.text
    property alias bottomInputText: addressInput.text
    property bool bottomInputIsPassword: false
    property variant favoriteItem: undefined
    property bool bottomVisible: true

    signal closePopup

    function okClicked() {
        if (favoriteItem) {
            favoriteItem.name = descriptionInput.text
            if (favoriteItem.address)
                favoriteItem.address = addressInput.text
        }
    }

    function cancelClicked() {
    }

    function selectAll() {
        descriptionInput.selectAll()
    }

    spacing: 4

    onFavoriteItemChanged: {
        if (favoriteItem !== undefined)
        {
            descriptionInput.text = favoriteItem.name
            if (favoriteItem.address) {
                addressInput.text = favoriteItem.address
            }
            else {
                addressInputBg.visible = false
                addressText.visible = false
            }
        }
    }
    Component.onCompleted: descriptionInput.forceActiveFocus()

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
            id: popupTitle
            text: qsTr("Edit quicklink properties")
            font.pixelSize: 24
            color: "white"
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_testo.svg"

        Flickable {
            id: flick

            anchors.fill: parent
            interactive: false
            clip: true

            function ensureVisible(r) {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX + width <= r.x + r.width)
                    contentX = r.x + r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY + height <= r.y + r.height)
                    contentY = r.y + r.height - height;
            }

            Column {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                spacing: 3

                UbuntuLightText {
                    id: titleText
                    font.pixelSize: 14
                    color: "white"
                    text: qsTr("Title:")
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SvgImage {
                    source: "../images/common/bg_text-input.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    UbuntuLightTextInput {
                        id: descriptionInput
                        text: "Title goes here."
                        font.pixelSize: 14
                        color: "#5A5A5A"
                        focus: true
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        containerWidget: popup
                        onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            descriptionInput.forceActiveFocus()
                            descriptionInput.openSoftwareInputPanel()
                        }
                    }
                }

                UbuntuLightText {
                    id: addressText
                    visible: bottomVisible
                    font.pixelSize: 14
                    color: "white"
                    text: qsTr("Address:")
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SvgImage {
                    id: addressInputBg
                    visible: bottomVisible
                    source: "../images/common/bg_text-input.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    UbuntuLightTextInput {
                        id: addressInput
                        text: "Address goes here."
                        font.pixelSize: 14
                        color: "#5A5A5A"
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }
                        containerWidget: popup
                        onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                        echoMode: popup.bottomInputIsPassword ? TextInput.Password : TextInput.Normal
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            addressInput.forceActiveFocus()
                            addressInput.openSoftwareInputPanel()
                        }
                    }
                }
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_ok_annulla.svg"

        Row {
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("ok")
                font.pixelSize: 14
                onPressed: {
                    popup.okClicked()
                    closePopup()
                }
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("cancel")
                font.pixelSize: 14
                onPressed: {
                    popup.cancelClicked()
                    popup.closePopup()
                }
            }
        }
    }
}
