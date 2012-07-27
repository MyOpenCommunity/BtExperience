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
                        leftMargin: 22
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: 24
                    color: "white"
                    text: scenarioObject.name
                }
            }

            SvgImage {
                source: "images/common/bg_scenevo.svg"

                Item {
                    anchors {
                        leftMargin: 22
                        left: parent.left
                        right: parent.right
                        rightMargin: 22
                        top: parent.top
                        topMargin: 20
                    }

                    AdvancedScenarioDateTimeCondition {
                        scenarioObject: page.scenarioObject
                        anchors.left: parent.left
                        anchors.top: parent.top
                    }

                    AdvancedScenarioDeviceCondition {
                        scenarioDeviceObject: page.scenarioObject.deviceCondition
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                    }

                    AdvancedScenarioAction {
                        anchors.right: parent.right
                        anchors.top: parent.top
                    }
                }
            }

            SvgImage {
                source: "images/common/bg_scenevo_ok_annulla.svg"


                UbuntuLightText {
                    text: qsTr("save changes?")
                    font.pixelSize: 14
                    color: "white"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: okButton.left
                        rightMargin: 10
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
                }

                ButtonThreeStates {
                    id: cancelButton

                    defaultImage: "images/common/btn_99x35.svg"
                    pressedImage: "images/common/btn_99x35_P.svg"
                    selectedImage: "images/common/btn_99x35_S.svg"
                    shadowImage: "images/common/btn_shadow_99x35.svg"
                    text: qsTr("CANCEL")
                    font.pixelSize: 14
                    onClicked: Stack.popPage()
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 7
                    }
                }
            }
        }
    }


}

