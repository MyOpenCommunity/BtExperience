import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    SvgImage {
        id: background
        source: "../../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    QtObject {
        id: privateProps
        function getMonthName(index) {
            switch (index) {
            case 0:
                return qsTr("January")
            case 1:
                return qsTr("February")
            case 2:
                return qsTr("March")
            case 3:
                return qsTr("April")
            case 4:
                return qsTr("May")
            case 5:
                return qsTr("June")
            case 6:
                return qsTr("July")
            case 7:
                return qsTr("August")
            case 8:
                return qsTr("September")
            case 9:
                return qsTr("October")
            case 10:
                return qsTr("November")
            case 11:
                return qsTr("December")
            }
        }
        property int currentIndex: -1
    }

    Column {
        SvgImage {
            source: "../../images/common/panel_switch.svg";

            UbuntuLightText {

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width / 100 * 4
                    right: switchThresholds.left
                    rightMargin: parent.width / 100 * 4
                }
                font.pixelSize: 13
                color: "white"
                text: qsTr("goals enabled")
                wrapMode: Text.WordWrap
            }

            Switch {
                id: switchThresholds
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: parent.width / 100 * 4
                }

                status: 0
            }
        }

        Component {
            id: panelComponent
            SettingsEnergyGoalPanel {
            }
        }

        PaginatorColumn {
            maxHeight: 300
            Repeater {
                MenuItem {
                    name: privateProps.getMonthName(index)
                    description: "140kwh"
                    hasChild: true
                    isSelected: privateProps.currentIndex === index
                    onClicked: {
                        privateProps.currentIndex = index
                        column.loadColumn(panelComponent, privateProps.getMonthName(index))
                    }
                }
                model: 12
            }
        }
    }
}
