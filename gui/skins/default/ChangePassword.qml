import QtQuick 1.1
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


Page {
    id: page

    source: homeProperties.homeBgImage
    showSystemsButton: false
    text: qsTr("Change password")

    Component.onCompleted: oldPasswordInput.forceActiveFocus()

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
                            leftMargin: Math.round(parent.width / 100 * 2)
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
                                anchors.fill: parent
                                onPressed: {
                                    oldPasswordInput.forceActiveFocus()
                                    oldPasswordInput.openSoftwareInputPanel()
                                }
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
                            rightMargin: Math.round(parent.width / 100 * 2)
                            verticalCenter: parent.verticalCenter
                        }

                        Component {
                            id: wrongPasswordFeedback
                            FeedbackPopup {
                                text: qsTr("Wrong password")
                                isOk: false
                            }
                        }

                        Component {
                            id: unmatchPasswordFeedback
                            FeedbackPopup {
                                text: qsTr("Passwords don't match")
                                isOk: false
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
                                    page.installPopup(wrongPasswordFeedback)
                                    return
                                }
                                if (newPasswordInput.text !== repeatPasswordInput.text) {
                                    page.installPopup(unmatchPasswordFeedback)
                                    return
                                }
                                global.password = newPasswordInput.text
                                Stack.popPage()
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
