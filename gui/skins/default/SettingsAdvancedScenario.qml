import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack

Page {
    id: page
    property variant scenarioObject: undefined

    text: qsTr("Advanced scenario")
    source: "images/bg2.jpg"

    Item {
        anchors {
            left: navigationBar.right
            right: parent.right
            top: navigationBar.top
        }

        Column {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter
            SvgImage {
                source: "images/common/bg_scenevo_titolo.svg"

                UbuntuLightText {
                    anchors {
                        left: parent.left
                        leftMargin: parent.width / 100 * 3
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: 24
                    color: "white"
                    text: scenarioObject.name
                }
            }

            Item {
                width: bodyImage.width
                height: bodyImage.height

                SvgImage {
                    id: bodyImage
                    source: "images/common/bg_scenevo.svg"
                }

                Item {
                    anchors {
                        leftMargin: parent.width / 100 * 3
                        left: parent.left
                        right: parent.right
                        rightMargin: parent.width / 100 * 3
                        top: parent.top
                        topMargin: parent.height / 100 * 6
                    }

                    AdvancedScenarioDateTimeCondition {
                        scenarioObject: page.scenarioObject
                        anchors {
                            left: parent.left
                            top: parent.top
                        }
                    }

                    AdvancedScenarioDeviceCondition {
                        scenarioDeviceObject: page.scenarioObject.deviceCondition
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                        }
                    }

                    AdvancedScenarioAction {
                        scenarioAction: page.scenarioObject.action
                        anchors {
                            right: parent.right
                            top: parent.top
                        }
                    }
                }
            }

            Item {
                width: bottomImage.width
                height: bottomImage.height

                SvgImage {
                    id: bottomImage
                    source: "images/common/bg_scenevo_ok_annulla.svg"
                }


                UbuntuLightText {
                    text: qsTr("save changes?")
                    font.pixelSize: 14
                    color: "white"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: okButton.left
                        rightMargin: parent.width / 100 * 1
                    }
                }

                ButtonThreeStates {
                    id: okButton

                    defaultImage: "images/common/btn_99x35.svg"
                    pressedImage: "images/common/btn_99x35_P.svg"
                    selectedImage: "images/common/btn_99x35_S.svg"
                    shadowImage: "images/common/btn_shadow_99x35.svg"
                    text: qsTr("OK")
                    font.pixelSize: 14
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: cancelButton.left
                    }
                    onClicked: {
                        scenarioObject.save()
                        Stack.popPage()
                    }

                }

                ButtonThreeStates {
                    id: cancelButton

                    defaultImage: "images/common/btn_99x35.svg"
                    pressedImage: "images/common/btn_99x35_P.svg"
                    selectedImage: "images/common/btn_99x35_S.svg"
                    shadowImage: "images/common/btn_shadow_99x35.svg"
                    text: qsTr("CANCEL")
                    font.pixelSize: 14

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: parent.width / 100 * 1
                    }
                    onClicked: {
                        // The reset must be called outside the page, before showing it
                        // otherwise the user can see the value changing during the
                        // transition effect.
                        Stack.popPage()
                    }
                }
            }
        }
    }


}

