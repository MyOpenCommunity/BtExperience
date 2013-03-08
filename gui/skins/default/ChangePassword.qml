import QtQuick 1.1
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManager


Page {
    id: page

    property variant names: translations

    source: homeProperties.homeBgImage
    showSystemsButton: false
    text: qsTr("Change password")

    Component.onCompleted: oldPasswordInputArea.setFocus()

    function alertOkClicked() {
        global.password = newPasswordInput.text
        EventManager.eventManager.notificationsEnabled = false
        Stack.backToHome({state: "pageLoading"})
    }

    Names {
        id: translations
    }

    Pannable {
        anchors.fill: parent

        Item {
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height

            Column {
                id: mainPanel
                anchors.centerIn: parent
                spacing: 2

                SvgImage {
                    source: "images/scenarios/bg_titolo.svg"

                    UbuntuMediumText {
                        id: title
                        text: qsTr("Change password")
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
                    source: "images/scenarios/bg_testo.svg"
                    height: 190

                    Column {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                        }

                        spacing: 2

                        UbuntuLightText {
                            font.pixelSize: 14
                            color: "white"
                            text: qsTr("Insert old password:")
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        SvgImage {
                            source: "images/common/bg_text-input.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            UbuntuLightTextInput {
                                id: oldPasswordInput
                                font.pixelSize: 14
                                color: "#5A5A5A"
                                echoMode: TextInput.Password
                                horizontalAlignment: Text.AlignHCenter
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    right: parent.right
                                    rightMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                containerWidget: mainPanel
                            }
                            MouseArea {
                                id: oldPasswordInputArea
                                anchors.fill: parent
                                function setFocus() {
                                    oldPasswordInput.forceActiveFocus()
                                    oldPasswordInput.openSoftwareInputPanel()
                                }
                                onPressed: setFocus()
                            }
                        }

                        UbuntuLightText {
                            font.pixelSize: 14
                            color: "white"
                            text: qsTr("Insert new password:")
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        SvgImage {
                            source: "images/common/bg_text-input.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            UbuntuLightTextInput {
                                id: newPasswordInput
                                font.pixelSize: 14
                                color: "#5A5A5A"
                                echoMode: TextInput.Password
                                horizontalAlignment: Text.AlignHCenter
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    right: parent.right
                                    rightMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                containerWidget: mainPanel
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed: {
                                    newPasswordInput.forceActiveFocus()
                                    newPasswordInput.openSoftwareInputPanel()
                                }
                            }
                        }

                        UbuntuLightText {
                            font.pixelSize: 14
                            color: "white"
                            text: qsTr("Repeat new password:")
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        SvgImage {
                            source: "images/common/bg_text-input.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            UbuntuLightTextInput {
                                id: repeatPasswordInput
                                font.pixelSize: 14
                                color: "#5A5A5A"
                                echoMode: TextInput.Password
                                horizontalAlignment: Text.AlignHCenter
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    right: parent.right
                                    rightMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
                                containerWidget: mainPanel
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed: {
                                    repeatPasswordInput.forceActiveFocus()
                                    repeatPasswordInput.openSoftwareInputPanel()
                                }
                            }
                        }
                    }
                }

                SvgImage {
                    source: "images/scenarios/bg_ok_annulla.svg"

                    Row {
                        anchors {
                            right: parent.right
                            rightMargin: parent.width / 100 * 2
                            verticalCenter: parent.verticalCenter
                        }

                        Component {
                            id: passwordFeedback
                            FeedbackPopup {
                                isOk: false
                                onClosePopup: {
                                    oldPasswordInput.text = ""
                                    newPasswordInput.text = ""
                                    repeatPasswordInput.text = ""
                                    oldPasswordInputArea.setFocus()
                                }
                            }
                        }

                        ButtonThreeStates {
                            defaultImage: "images/common/btn_99x35.svg"
                            pressedImage: "images/common/btn_99x35_P.svg"
                            selectedImage: "images/common/btn_99x35_S.svg"
                            shadowImage: "images/common/btn_shadow_99x35.svg"
                            text: qsTr("ok")
                            font.pixelSize: 14
                            onPressed: {
                                if (global.password !== oldPasswordInput.text) {
                                    page.installPopup(passwordFeedback, { text: qsTr("Wrong password") })
                                    return
                                }
                                if (newPasswordInput.text !== repeatPasswordInput.text) {
                                    page.installPopup(passwordFeedback, { text: qsTr("Passwords don't match") })
                                    return
                                }
                                if (newPasswordInput.text === "") {
                                    page.installPopup(passwordFeedback, { text: qsTr("New password is empty") })
                                    return
                                }
                                oldPasswordInput.focus = false
                                newPasswordInput.focus = false
                                repeatPasswordInput.focus = false
                                page.showAlert(page, page.names.get('REBOOT', 0))
                            }
                        }

                        ButtonThreeStates {
                            defaultImage: "images/common/btn_99x35.svg"
                            pressedImage: "images/common/btn_99x35_P.svg"
                            selectedImage: "images/common/btn_99x35_S.svg"
                            shadowImage: "images/common/btn_shadow_99x35.svg"
                            text: qsTr("cancel")
                            font.pixelSize: 14
                            onPressed: Stack.popPage()
                        }
                    }
                }
            }
        }
    }
}
