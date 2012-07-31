import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "../../js/datetime.js" as DateTime


MenuColumn {
    id: element

    AnimatedLoader {
        id: applianceLoader

        anchors.top: parent.top
        onItemChanged: {
            // TODO when loaded item changes menu height is not updated
            // this trick is to force height update
            if (item) {
                element.height = item.height
                element.width = item.width
            }
        }
    }

    QtObject {
        id: privateProps

        function loadEnabled() {
            return element.dataModel.hasControlUnit && element.dataModel.loadEnabled
        }

        function computeSince(period) {
            // datetime returned from resetDateTime may be invalid; in this
            // case we have to compare it with empty string, but using the
            // == operator (and not === operator) because dt is not a string
            var dt = period.resetDateTime
            var d = DateTime.format(dt)["date"]
            if (d == "")
                return ""
            var t = DateTime.format(dt)["time"]
            return qsTr("since ") + d + " - " + t
        }
    }

    Component.onCompleted: {
        element.dataModel.requestConsumptionUpdateStart()
        element.dataModel.requestLoadStatus()
        if (element.dataModel.hasControlUnit)
            element.dataModel.requestTotals()
    }
    Component.onDestruction: element.dataModel.requestConsumptionUpdateStop()

    state: privateProps.loadEnabled() ? "forced" : "normal"

    states: [
        State {
            name: "forced"
            StateChangeScript { script: applianceLoader.setComponent(applianceForced); }
        },
        State {
            name: "normal"
            StateChangeScript { script: applianceLoader.setComponent(appliance); }
        }
    ]

    Component {
        id: applianceForced

        // in this Component we assume a CU is available for the load (if a CU
        // is not present this submenu is a nosense)
        Column {
            ControlMinusPlus {
                title: qsTr("force load")
                text: element.dataModel.forceDuration + qsTr(" minutes")
                onMinusClicked: element.dataModel.decreaseForceDuration()
                onPlusClicked: element.dataModel.increaseForceDuration()
            }

            SvgImage {
                source: "../../images/common/bg_on-off.svg"

                ButtonThreeStates {
                    id: buttonForce

                    defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
                    pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
                    shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
                    text: qsTr("force load")
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 15
                    onClicked: element.dataModel.forceOn(element.dataModel.forceDuration)
                    status: 0
                    anchors.centerIn: parent
                }
            }
        }
    }

    Component {
        id: appliance

        Column {
            SvgImage {
                visible: element.dataModel.hasControlUnit
                source: "../../images/common/bg_on-off.svg"

                UbuntuLightText {
                    text: qsTr("device")
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 15
                        left: parent.left
                        leftMargin: parent.width / 100 * 5
                    }
                }

                UbuntuLightText {
                    // the following test is "simplified" because the switch is
                    // visible only if the load has a CU: if CU is not present
                    // the switch is not visible
                    text: privateProps.loadEnabled() ? qsTr("enabled") : qsTr("disabled")
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: parent.height / 100 * 15
                        left: parent.left
                        leftMargin: parent.width / 100 * 5
                    }
                }

                Switch {
                    bgImage: "../../images/common/bg_cursore.svg"
                    leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                    leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                    arrowImage: "../../images/common/ico_sposta_dx.svg"
                    rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                    rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                    status: 0
                    anchors {
                        right: parent.right
                        rightMargin: width / 100 * 8
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: privateProps.loadEnabled() && element.dataModel.loadForced ?
                                   element.dataModel.stopForcing() :
                                   element.dataModel.forceOn()
                }
            }

            SvgImage {
                source: "../../images/common/bg_on-off.svg"

                UbuntuLightText {
                    text: qsTr("instant consumption")
                    color: "gray"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors {
                        top: parent.top
                        topMargin: parent.height / 100 * 15
                        left: parent.left
                        leftMargin: parent.width / 100 * 5
                    }
                }

                UbuntuLightText {
                    text: element.dataModel.consumption + " " + element.dataModel.currentUnit
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: parent.height / 100 * 15
                        left: parent.left
                        leftMargin: parent.width / 100 * 5
                    }
                }
            }

            Partial {
                partialId: 0 // expects periodTotals are zero-based
                visible: element.dataModel.hasConsumptionMeters
                text: element.dataModel.periodTotals[partialId].total + " " + element.dataModel.cumulativeUnit
                since: privateProps.computeSince(element.dataModel.periodTotals[partialId])
                onClicked: element.dataModel.resetTotal(partialId)
            }

            Partial {
                partialId: 1
                visible: element.dataModel.hasConsumptionMeters
                text: element.dataModel.periodTotals[partialId].total + " " + element.dataModel.cumulativeUnit
                since: privateProps.computeSince(element.dataModel.periodTotals[partialId])
                onClicked: element.dataModel.resetTotal(partialId)
            }
        }
    }
}
