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
import Components.Popup 1.0


MenuColumn {
    id: column

    Column {
        MenuItem {
            name: privateProps.isProgramming ? qsTr("stop programming") : qsTr("start programming")
            onTouched: privateProps.startClicked()
        }

        MenuItem {
            name: qsTr("Delete scenario")
            onTouched: privateProps.deleteProgram()
        }
    }

    QtObject {
        id: privateProps

        property int errorTimeout: 2000
        property int isProgramming: column.dataModel.status === ScenarioModule.Editing

        function startClicked() {
            switch (column.dataModel.status)
            {
            case ScenarioModule.Locked:
                pageObject.installPopup(scenarioLocked)
                break
            case ScenarioModule.Unlocked:
                pageObject.installPopup(scenarioProgramming)
                break
            case ScenarioModule.Editing:
                column.dataModel.stopProgramming()
                break
            }
        }

        function deleteProgram() {
            if (column.dataModel.status === ScenarioModule.Locked)
                pageObject.installPopup(scenarioLocked)
            else
                pageObject.installPopup(confirmDelete)
        }
    }

    Component {
        id: scenarioLocked
        FeedbackPopup {
            text: qsTr("programming impossible")
            isOk: false
        }
    }

    Component {
        id: scenarioProgramming

        TextDialog {
            function okClicked() {
                column.dataModel.startProgramming()
            }

            title: qsTr("Scenario configuration")
            text: qsTr("If you didn't cancel the scenario, you will add \
actions to the pre-existing scenario. Press OK if you want to start scenario programming, \
CANCEL if you wish to abort the operation.")
        }
    }

    Component {
        id: confirmDelete
        Column {
            id: confirmDeleteColumn
            signal closePopup

            spacing: 4

            SvgImage {
                source: "../../images/scenarios/bg_titolo.svg"

                UbuntuMediumText {
                    text: qsTr("Are you sure to reset the scenario?")
                    font.pixelSize: 24
                    color: "white"
                    anchors {
                        left: parent.left
                        leftMargin: parent.width / 100 * 2
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                }
            }
            SvgImage {
                source: "../../images/scenarios/bg_ok_annulla.svg"

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        verticalCenter: parent.verticalCenter
                    }

                    ButtonThreeStates {
                        defaultImage: "../../images/common/btn_99x35.svg"
                        pressedImage: "../../images/common/btn_99x35_P.svg"
                        selectedImage: "../../images/common/btn_99x35_S.svg"
                        shadowImage: "../../images/common/btn_shadow_99x35.svg"
                        text: qsTr("ok")
                        font.pixelSize: 14
                        onPressed: {
                            column.dataModel.deleteScenario()
                            confirmDeleteColumn.closePopup()
                        }
                    }

                    ButtonThreeStates {
                        defaultImage: "../../images/common/btn_99x35.svg"
                        pressedImage: "../../images/common/btn_99x35_P.svg"
                        selectedImage: "../../images/common/btn_99x35_S.svg"
                        shadowImage: "../../images/common/btn_shadow_99x35.svg"
                        text: qsTr("cancel")
                        font.pixelSize: 14
                        onPressed: confirmDeleteColumn.closePopup()
                    }
                }
            }
        }
    }
}
