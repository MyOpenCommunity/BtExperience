import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    Column {
        MenuItem {
            name: qsTr("start programming")
            onClicked: privateProps.startProgramming()
        }

        MenuItem {
            name: qsTr("reset program")
            onClicked: privateProps.deleteProgram()
        }
    }

    QtObject {
        id: privateProps

        property int errorTimeout: 2000

        function startProgramming() {
            if (column.dataModel.status === ScenarioModule.Locked)
                pageObject.installPopup(scenarioLocked)
            else
                pageObject.installPopup(scenarioProgramming)
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
        SvgImage {
            signal closePopup

            source: "../../images/scenarios/bg_feedback.svg"

            SvgImage {
                id: icon
                source: "../../images/scenarios/ico_error.svg"
                anchors.left: parent.left
            }

            UbuntuMediumText {
                text: qsTr("programming impossible")
                anchors {
                    left: icon.right
                    leftMargin: parent.width / 100 * 2
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 18
            }

            Timer {
                interval: privateProps.errorTimeout
                running: true
                onTriggered: parent.closePopup()
            }
        }
    }

    Component {
        id: scenarioProgramming
        Column {
            id: scenarioProgrammingColumn
            signal closePopup

            spacing: 4

            SvgImage {
                source: "../../images/scenarios/bg_titolo.svg"

                UbuntuMediumText {
                    text: qsTr("Scenario configuration")
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
                source: "../../images/scenarios/bg_testo.svg"

                UbuntuMediumText {
                    font.pixelSize: 14
                    color: "white"
                    text: qsTr("If you didn't do a scenario reset, you will add \
actions to the scenario. Press OK if you want to start scenario programming, \
CANCEL if you wish to abort the operation.")
                    wrapMode: Text.Wrap
                    anchors {
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        left: parent.left
                        leftMargin: parent.width / 100 * 2
                    }
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
                        onClicked: {
                            column.dataModel.startProgramming()
                            scenarioProgrammingColumn.closePopup()
                        }
                    }

                    ButtonThreeStates {
                        defaultImage: "../../images/common/btn_99x35.svg"
                        pressedImage: "../../images/common/btn_99x35_P.svg"
                        selectedImage: "../../images/common/btn_99x35_S.svg"
                        shadowImage: "../../images/common/btn_shadow_99x35.svg"
                        text: qsTr("cancel")
                        font.pixelSize: 14
                        onClicked: scenarioProgrammingColumn.closePopup()
                    }
                }
            }
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
                        verticalCenter: parent.verticalCenter
                    }
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
                        onClicked: {
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
                        onClicked: confirmDeleteColumn.closePopup()
                    }
                }
            }
        }
    }
}
