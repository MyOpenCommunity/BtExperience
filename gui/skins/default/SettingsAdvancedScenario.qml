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
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0
import "js/Stack.js" as Stack


Page {
    id: page

    property variant scenarioObject: undefined

    text: qsTr("Advanced scenario")
    source : homeProperties.homeBgImage

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
                        right: parent.right
                        rightMargin: parent.width / 100 * 3
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: 24
                    color: "white"
                    text: scenarioObject.name
                    elide: Text.ElideRight
                }
            }

            Item {
                width: bodyImage.width
                height: bodyImage.height

                SvgImage {
                    id: bodyImage
                    source: "images/common/bg_scenevo.svg"
                }

                Row {
                    spacing: 3.5 / 100 * parent.width
                    anchors {
                        leftMargin: parent.width / 100 * 3
                        left: parent.left
                        top: parent.top
                        topMargin: parent.height / 100 * 6
                    }

                    AdvancedScenarioDateTimeCondition {
                        id: timeCondition
                        scenarioObject: page.scenarioObject
                        anchors.top: parent.top
                    }

                    Loader {
                        sourceComponent: page.scenarioObject.deviceCondition !== null ? deviceConditionComponent : undefined
                        Component {
                            id: deviceConditionComponent
                            AdvancedScenarioDeviceCondition {
                                id: deviceCondition
                                scenarioDeviceObject: page.scenarioObject.deviceCondition
                                anchors.top: parent.top
                            }
                        }

                    }

                    AdvancedScenarioAction {
                        id: action
                        scenarioAction: page.scenarioObject.action
                        anchors.top: parent.top
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
                    text: qsTr("Save changes?")
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
                    onPressed: {
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
                    onPressed: {
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

